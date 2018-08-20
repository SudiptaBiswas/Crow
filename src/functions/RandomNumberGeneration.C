/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "MooseRandom.h"
#include "RandomNumberGeneration.h"
#include "libmesh/point.h"

registerMooseObject("CrowApp", RandomNumberGeneration);

template <> InputParameters validParams<RandomNumberGeneration>() {
  InputParameters params = validParams<Function>();
  params.addParam<Real>("min", 0.0,
                        "Lower bound of the randomly generated values");
  params.addParam<Real>("max", 1.0,
                        "Upper bound of the randomly generated values");
  params.addParam<unsigned int>("seed", 0,
                                "Seed value for the random number generator");

  return params;
}

RandomNumberGeneration::RandomNumberGeneration(
    const InputParameters &parameters)
    : Function(parameters), _min(getParam<Real>("min")),
      _max(getParam<Real>("max")), _range(_max - _min) {
  mooseAssert(_range > 0.0, "Min > Max for RandomIC!");
  MooseRandom::seed(getParam<unsigned int>("seed"));
}

RandomNumberGeneration::~RandomNumberGeneration() {}

Real RandomNumberGeneration::value(Real /*t*/, const Point & /*p*/) {
  // Random number between 0 and 1
  Real rand_num = MooseRandom::rand();

  // Between 0 and range
  rand_num *= _range;

  // Between min and max
  rand_num += _min;

  return rand_num;
}

// Real
// RandomNumberGeneration::timeDerivative(Real t, const Point & p)
//{
// return 0.0;
//}

// Real
// RandomNumberGeneration::integral()
//{
//  return 0.0;
//}

// Real
// RandomNumberGeneration::average()
//{
// return
// integral()/(_linear_interp->domain(_linear_interp->getSampleSize()-1)-_linear_interp->domain(0));
//}
