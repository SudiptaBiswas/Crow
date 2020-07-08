#include "MooseMesh.h"
#include "MooseRandom.h"
#include "TwoParticleDensityIC.h"

registerMooseObject("CrowApp", TwoParticleDensityIC);

template <> InputParameters validParams<TwoParticleDensityIC>() {
  InputParameters params = validParams<InitialCondition>();
  // params.addParam<Real>("min", 0.0, "Lower bound of the randomly generated
  // values");  params.addParam<Real>("max", 1.0, "Upper bound of the randomly
  // generated values");  params.addParam<unsigned int>("seed", 0, "Seed value
  // for the random number generator");
  params.addParam<Real>("tol", 1e-6,
                        "Upper bound of the randomly generated values");
  params.addRequiredParam<unsigned int>("op_num",
                                        "Number of grain order parameters");
  params.addRequiredParam<std::vector<Real>>(
      "radius", "radius of the particles given as a vector input: r1, r2");

  return params;
}

TwoParticleDensityIC::TwoParticleDensityIC(const InputParameters &parameters)
    : InitialCondition(parameters), _mesh(_fe_problem.mesh()),
      _nl(_fe_problem.getNonlinearSystem()),
      //_minvalue(getParam<Real>("min")),
      //_maxvalue(getParam<Real>("max")),
      //_rangevalue(_maxvalue - _minvalue),
      _tol(getParam<Real>("tol")), _op_num(getParam<unsigned int>("op_num")),
      _radius(getParam<std::vector<Real>>("radius"))

{
  if (_op_num != 2)
    mooseError("Two Particle ICs must have op_num = 2");

  // Set up domain bounds with mesh tools
  for (unsigned int i = 0; i < LIBMESH_DIM; i++) {
    _bottom_left(i) = _mesh.getMinInDimension(i);
    _top_right(i) = _mesh.getMaxInDimension(i);
  }
  _rangedomain = _top_right - _bottom_left;

  // MooseRandom::seed(getParam<unsigned int>("seed"));
}

Real TwoParticleDensityIC::value(const Point &p) {
  // Real rand_num = MooseRandom::rand();

  // Between 0 and range
  // rand_num *= _rangevalue;

  // Between min and max
  // rand_num += _minvalue;

  ////////////////////////////////////////

  Real radius_left = _radius[0];
  Real radius_right = _radius[1];

  Point grain_center_left;
  grain_center_left(0) = _bottom_left(0) + _rangedomain(0) / 2.0 - radius_left;
  grain_center_left(1) = _bottom_left(1) + _rangedomain(1) / 2.0;
  grain_center_left(2) = _bottom_left(2) + _rangedomain(2) / 2.0;

  Point grain_center_right;
  grain_center_right(0) =
      _bottom_left(0) + _rangedomain(0) / 2.0 + radius_right;
  grain_center_right(1) = _bottom_left(1) + _rangedomain(1) / 2.0;
  grain_center_right(2) = _bottom_left(2) + _rangedomain(2) / 2.0;

  // Real radius = _range(0)/5.0;
  Real dist_left = (p - grain_center_left).norm();
  Real dist_right = (p - grain_center_right).norm();

  for (unsigned int _op_index = 0.0; _op_index < _op_num; _op_index++) {
    if ((dist_left <= radius_left && _op_index == 0) ||
        (dist_right <= radius_right && _op_index == 1))
      return 1.0 - _tol;
  }
  return 0.0 + _tol;
}
