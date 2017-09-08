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

#include "InterfaceAreaPostprocessor.h"

template<>
InputParameters validParams<InterfaceAreaPostprocessor>()
{
  InputParameters params = validParams<ElementIntegralVariablePostprocessor>();
  return params;
}

InterfaceAreaPostprocessor::InterfaceAreaPostprocessor(const InputParameters & parameters) :
    ElementIntegralVariablePostprocessor(parameters)
{
}

Real
InterfaceAreaPostprocessor::computeQpIntegral()
{
  Real c = 0.0;
  // if (_u[_qp] > 0.1 && _u[_qp] < 0.95)
  //   c = 1.0;
  if (_u[_qp] > 0.45 && _u[_qp] < 0.55)
    c = 1.0;
  return c;
}
