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

#include "BicrystalIC.h"
#include "libmesh/point.h"

registerMooseObject("CrowApp", BicrystalIC);

template <> InputParameters validParams<BicrystalIC>() {
  InputParameters params = validParams<InitialCondition>();
  params.addRequiredParam<Real>(
      "x1", "The x coordinate of the lower left-hand corner of the box");
  params.addRequiredParam<Real>(
      "y1", "The y coordinate of the lower left-hand corner of the box");
  params.addParam<Real>(
      "z1", 0.0, "The z coordinate of the lower left-hand corner of the box");

  params.addRequiredParam<Real>(
      "x2", "The x coordinate of the upper right-hand corner of the box");
  params.addRequiredParam<Real>(
      "y2", "The y coordinate of the upper right-hand corner of the box");
  params.addParam<Real>(
      "z2", 0.0, "The z coordinate of the upper right-hand corner of the box");

  params.addParam<Real>("inside", 0.0,
                        "The value of the variable inside the box");
  params.addParam<Real>("outside", 0.0,
                        "The value of the variable outside the box");

  params.addParam<Real>("int_width", 0.0, "Width of the interface");
  MooseEnum side_options("left right");
  params.addParam<MooseEnum>("grain_side", side_options,
                             " specify the grain side as left/right");

  return params;
}

BicrystalIC::BicrystalIC(const InputParameters &parameters)
    : InitialCondition(parameters), _x1(getParam<Real>("x1")),
      _y1(getParam<Real>("y1")), _z1(getParam<Real>("z1")),
      _x2(getParam<Real>("x2")), _y2(getParam<Real>("y2")),
      _z2(getParam<Real>("z2")), _inside(getParam<Real>("inside")),
      _outside(getParam<Real>("outside")), _bottom_left(_x1, _y1, _z1),
      _top_right(_x2, _y2, _z2), _int(getParam<Real>("int_width")),
      _grain_side(getParam<MooseEnum>("grain_side")) {}

Real BicrystalIC::value(const Point &p) {
  switch (_grain_side) {
  case 0: {
    // for (unsigned int i=0; i<LIBMESH_DIM; i++)
    // if (p(0) <= _bottom_left(0)-_int/2.0 || p(0) >= _top_right(0)+_int/2.0)
    // return _outside;
    // else if (p(0) > _bottom_left(0)-_int/2.0 && p(0) <
    // _bottom_left(0)+_int/2.0 || p(0) > _top_right(0)-_int/2.0 && p(0) <
    // _top_right(0)+_int/2.0)  return _outside + (_inside-_outside)*p(0)/_int;
    if (p(0) >= _top_right(0) + _int / 2.0)
      return _outside;
    else if (p(0) > _top_right(0) - _int / 2.0 &&
             p(0) < _top_right(0) + _int / 2.0)
      return _outside +
             (_inside - _outside) * (_top_right(0) + _int / 2.0 - p(0)) / _int;

    return _inside;
  }

  case 1: {
    if (p(0) <= _bottom_left(0) - _int / 2.0)
      return _outside;
    else if (p(0) > _bottom_left(0) - _int / 2.0 &&
             p(0) < _bottom_left(0) + _int / 2.0)
      return _outside + (_inside - _outside) *
                            (p(0) - _bottom_left(0) + _int / 2.0) / _int;

    return _inside;
  }
  }
  mooseError("Error in BicrystalIC");
}
