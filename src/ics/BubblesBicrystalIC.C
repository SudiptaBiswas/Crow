#include "BubblesBicrystalIC.h"
#include "MooseMesh.h"

// MOOSE includes
#include "MooseMesh.h"

// registerMooseObject("CrowApp", BubblesBicrystalIC);

template <> InputParameters validParams<BubblesBicrystalIC>() {
  InputParameters params = validParams<InitialCondition>();

  params.addClassDescription("Initial condition to set up multiple lenticular "
                             "pores along a straight bicrystal grain "
                             "boundary.");
  params.addRequiredParam<unsigned int>("phase", "The index for the current "
                                                 "crystal, where a value of 2 "
                                                 "indicates the bubble");
  params.addRequiredParam<unsigned int>("nbub",
                                        "The number of bubbles on a single GB");

  params.addRequiredParam<Real>("radius",
                                "The inner radius of the island grain");
  params.addRequiredParam<Real>("int_width",
                                "The initial width of the interface");
  params.addRequiredParam<Real>("theta", "The contact angle of the bubble");

  params.addParam<Real>("c_outvalue", 0.0,
                        "Concentration value outside of the bubble");

  return params;
}

BubblesBicrystalIC::BubblesBicrystalIC(const InputParameters &parameters)
    : InitialCondition(parameters), _mesh(_fe_problem.mesh()),
      _phase(getParam<unsigned int>("phase")),
      _nbub(getParam<unsigned int>("nbub")), _ra(getParam<Real>("radius")),
      _wi(getParam<Real>("int_width")), _theta(getParam<Real>("theta")),
      _c_outvalue(getParam<Real>("c_outvalue")) {}

void BubblesBicrystalIC::initialSetup() {
  // Set up domain bounds with mesh tools
  for (unsigned int i = 0; i < LIBMESH_DIM; i++) {
    _bottom_left(i) = _mesh.getMinInDimension(i);
    _top_right(i) = _mesh.getMaxInDimension(i);
  }
  _range = _top_right - _bottom_left;
}

Real BubblesBicrystalIC::value(const Point &p) {
  Real val = 0.0;
  Real x = p(0);
  Real w2 = _wi / 2.0;
  Real rcurv = _ra / std::sin(_theta * libMesh::pi / 180.0);
  Real rdisp = rcurv * std::cos(_theta * libMesh::pi / 180.0);

  // ------------------------------------------------------------------------
  // Define the Bicrystal...
  // ------------------------------------------------------------------------

  if (x <= _top_right(0) / 2 - w2) {
    if (_phase == 0)
      val = 1.0;
    if (_phase == 1)
      val = 0.0;
  }
  if (x >= _top_right(0) / 2 + w2) {
    if (_phase == 0)
      val = 0.0;
    if (_phase == 1)
      val = 1.0;
  }
  if (x > (_top_right(0) / 2 - w2) && x < (_top_right(0) / 2 + w2)) {
    Real rb = std::abs(x - (_top_right(0) / 2 - w2)) / _wi;
    Real hb = 1.0 - (3.0 * rb * rb - 2.0 * rb * rb * rb);
    if (_phase == 0)
      val = hb;
    if (_phase == 1)
      val = 1.0 - hb;
  }

  // Define the bubble centers...

  std::vector<Real> bubcent;
  bubcent.resize(_nbub);
  Real offset = _top_right(1) / _nbub / 2.0;

  for (unsigned int i = 0; i < _nbub; ++i) {
    bubcent[i] = offset;
    offset = offset + _top_right(1) / _nbub;
  }

  // ------------------------------------------------------------------------
  // Insert bubbles on grain boundary...
  // ------------------------------------------------------------------------

  for (unsigned int bub = 0; bub < _nbub; ++bub) {
    // Define center of lenticular bubble...

    Point bub_center = _bottom_left + _range / 2.0;
    if (x <= _top_right(0) / 2)
      bub_center(0) = bub_center(0) + rdisp;
    if (x > _top_right(0) / 2)
      bub_center(0) = bub_center(0) - rdisp;

    bub_center(1) = bubcent[bub];

    Real dist = (p - bub_center).norm();

    // Bubble interior...
    if (dist < rcurv) {
      if (_phase == 2)
        val = 1.0;
      if (_phase == 0 || _phase == 1)
        val = 0.0;
    }

    // Bubble interface...
    if (dist >= rcurv && dist <= (rcurv + _wi)) {
      Real rr = std::abs(dist - rcurv) / _wi;
      Real ii = (3.0 * rr * rr - 2.0 * rr * rr * rr);
      Real hh = 1.0 - ii;

      if (_phase == 2)
        val = 1.0 - ii * (1.0 - _c_outvalue);
      if (_phase == 0 || _phase == 1)
        if (val > 0.0)
          val = (1.0 - hh) * val;
    }

    // Outside of bubble...
    if (dist > (rcurv + _wi) && _phase == 2)
      val = _c_outvalue;
  }

  return val;
}
