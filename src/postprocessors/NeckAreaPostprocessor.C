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

#include "NeckAreaPostprocessor.h"

registerMooseObject("CrowApp", NeckAreaPostprocessor);

template <> InputParameters validParams<NeckAreaPostprocessor>() {
  InputParameters params = validParams<ElementIntegralPostprocessor>();
  params.addRequiredCoupledVarWithAutoBuild("v", "var_name_base", "op_num",
                                            "Array of coupled variables");
  return params;
}

NeckAreaPostprocessor::NeckAreaPostprocessor(const InputParameters &parameters)
    : ElementIntegralPostprocessor(parameters), _op_num(coupledComponents("v")),
      _vals(_op_num) {
  for (unsigned int i = 0; i < _op_num; ++i)
    _vals[i] = &coupledValue("v", i);
}

Real NeckAreaPostprocessor::computeQpIntegral() {
  Real gb = 0.0;
  for (unsigned int i = 0; i < _op_num; ++i)
    for (unsigned int j = 0; j < _op_num; ++j)
      if (i != j)
        gb = (*_vals[i])[_qp] * (*_vals[j])[_qp];

  // if (gb > 0.5 && _u[_qp] < 0.95)
  //   gb = 1.0;
  return gb;
}
