#include "MooseMesh.h"
#include "MooseRandom.h"
#include "TwoParticleGrainsIC.h"

registerMooseObject("CrowApp", TwoParticleGrainsIC);

template <> InputParameters validParams<TwoParticleGrainsIC>() {
  InputParameters params = validParams<InitialCondition>();
  params.addRequiredParam<unsigned int>("op_num",
                                        "Number of grain order parameters");
  params.addRequiredParam<unsigned int>(
      "op_index", "Index for the current grain order parameter");
  // params.addRequiredParam<std::vector<Real> >("radius", "radius of the
  // particles given as a vector input: r1, r2");

  return params;
}

TwoParticleGrainsIC::TwoParticleGrainsIC(const InputParameters &parameters)
    : InitialCondition(parameters), _mesh(_fe_problem.mesh()),
      _nl(_fe_problem.getNonlinearSystem()),
      _op_num(getParam<unsigned int>("op_num")),
      _op_index(getParam<unsigned int>("op_index"))
//_radius(getParam<std::vector<Real> >("radius"))
{
  if (_op_num != 2)
    mooseError("Two Particle ICs must have op_num = 2");

  // Set up domain bounds with mesh tools
  for (unsigned int i = 0; i < LIBMESH_DIM; i++) {
    _bottom_left(i) = _mesh.getMinInDimension(i);
    _top_right(i) = _mesh.getMaxInDimension(i);
  }
  _rangedomain = _top_right - _bottom_left;
}

Real TwoParticleGrainsIC::value(const Point &p) {
  //_redius.resize(2);
  Real radius_left = 5.0;  //_radius[0];
  Real radius_right = 5.0; //_radius[1];

  Point grain_center_left;
  grain_center_left(0) = _bottom_left(0) + _rangedomain(0) / 2.0 - radius_left;
  grain_center_left(1) = _bottom_left(1) + _rangedomain(1) / 2.0;
  grain_center_left(2) = _bottom_left(2) + _rangedomain(2) / 2.0;

  Point grain_center_right;
  grain_center_right(0) =
      _bottom_left(0) + _rangedomain(0) / 2.0 + radius_right;
  grain_center_right(1) = _bottom_left(1) + _rangedomain(1) / 2.0;
  grain_center_right(2) = _bottom_left(2) + _rangedomain(2) / 2.0;

  Real dist_left = (p - grain_center_left).norm();
  Real dist_right = (p - grain_center_right).norm();

  if ((dist_left <= radius_left && _op_index == 0) ||
      (dist_right <= radius_right && _op_index == 1))
    return 1.0;
  else
    return 0.0;
}
