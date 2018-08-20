/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "SinteringFreeEnergy.h"

registerMooseObject("CrowApp", SinteringFreeEnergy);

template <> InputParameters validParams<SinteringFreeEnergy>() {
  InputParameters params = validParams<DerivativeFunctionMaterialBase>();
  params.addClassDescription("Material that implements the sintering free "
                             "energy and its derivatives: \nF = 1/4(1 + "
                             "c)^2*(1 - c)^2");
  params.addRequiredCoupledVar("c", "Concentration variable");
  params.addCoupledVar("v", "Vector of all the coupled order parameters");
  params.addParam<MaterialPropertyName>(
      "A", "A", "The co-efficient used for free energy");
  params.addParam<MaterialPropertyName>(
      "B", "B", "The co-efficient used for free energy");
  return params;
}

SinteringFreeEnergy::SinteringFreeEnergy(const InputParameters &parameters)
    : DerivativeFunctionMaterialBase(parameters), _c(coupledValue("c")),
      _c_var(coupled("c")), _A(getMaterialProperty<Real>("A")),
      _B(getMaterialProperty<Real>("B")), _ncrys(coupledComponents("v")) {
  // Array of coupled variables is created in the constructor
  _vals.resize(_ncrys); // Size variable arrays
  _vals_var.resize(_ncrys);

  // Loop through grains and load coupled variables into the arrays
  for (unsigned int i = 0; i < _ncrys; ++i) {
    _vals[i] = &coupledValue("v", i);
    _vals_var[i] = coupled("v", i);
  }
}

Real SinteringFreeEnergy::computeF() {
  Real SumEtaj = 0.0;
  Real SumEtaj3 = 0.0;
  for (unsigned int i = 0; i < _ncrys; ++i) {
    SumEtaj +=
        (*_vals[i])[_qp] * (*_vals[i])[_qp]; // Sum all other order parameters
    SumEtaj3 += (*_vals[i])[_qp] * (*_vals[i])[_qp] * (*_vals[i])[_qp];
  }
  return _A[_qp] * _c[_qp] * _c[_qp] * (1.0 - _c[_qp]) * (1.0 - _c[_qp]) +
         _B[_qp] * (_c[_qp] * _c[_qp] + 6.0 * (1.0 - _c[_qp]) * SumEtaj -
                    4.0 * (2.0 - _c[_qp]) * SumEtaj3 + 3.0 * SumEtaj * SumEtaj);
}

Real SinteringFreeEnergy::computeDF(unsigned int j_var) {
  Real SumEtaj = 0.0;
  Real SumEtaj3 = 0.0;
  if (j_var == _c_var) // Note that these checks are only really necessary when
                       // the material has more than one coupled variable
  {
    for (unsigned int i = 0; i < _ncrys; ++i) {
      SumEtaj +=
          (*_vals[i])[_qp] * (*_vals[i])[_qp]; // Sum all other order parameters
      SumEtaj3 += (*_vals[i])[_qp] * (*_vals[i])[_qp] * (*_vals[i])[_qp];
    }
    return 4.0 * _A[_qp] * _c[_qp] * _c[_qp] * _c[_qp] -
           6.0 * _A[_qp] * _c[_qp] * _c[_qp] +
           2.0 * (_A[_qp] + _B[_qp]) * _c[_qp] - 6.0 * _B[_qp] * SumEtaj +
           4.0 * _B[_qp] * SumEtaj3;
  }

  for (unsigned int i = 0; i < _ncrys; ++i)
    if (j_var == _vals_var[i]) {
      SumEtaj +=
          (*_vals[i])[_qp] * (*_vals[i])[_qp]; // Sum all other order parameters
      return 12.0 * _B[_qp] * (1.0 - _c[_qp]) * (*_vals[i])[_qp] -
             12.0 * _B[_qp] * (2.0 - _c[_qp]) * (*_vals[i])[_qp] *
                 (*_vals[i])[_qp] +
             12.0 * _B[_qp] * SumEtaj * (*_vals[i])[_qp];
    }
  return 0.0;
}

Real SinteringFreeEnergy::computeD2F(unsigned int j_var, unsigned int k_var) {
  if ((j_var == _c_var) && (k_var == _c_var))
    return 12.0 * _A[_qp] * _c[_qp] * _c[_qp] - 12.0 * _A[_qp] * _c[_qp] +
           2.0 * (_A[_qp] + _B[_qp]);

  Real SumEtaj = 0.0;
  for (unsigned int i = 0; i < _ncrys; ++i) {
    if ((j_var == _c_var) && (k_var == _vals_var[i]))
      return -12.0 * _B[_qp] * (*_vals[i])[_qp] +
             12.0 * _B[_qp] * (*_vals[i])[_qp] * (*_vals[i])[_qp];

    if ((j_var == _vals_var[i]) && (k_var == _vals_var[i])) {
      SumEtaj +=
          (*_vals[i])[_qp] * (*_vals[i])[_qp]; // Sum all other order parameters
      return 12.0 * _B[_qp] * (1.0 - _c[_qp]) -
             24.0 * _B[_qp] * (2.0 - _c[_qp]) * (*_vals[i])[_qp] +
             12.0 * _B[_qp] * SumEtaj +
             24.0 * _B[_qp] * (*_vals[i])[_qp] * (*_vals[i])[_qp];
    }
  }
  return 0.0;
}

Real SinteringFreeEnergy::computeD3F(unsigned int j_var, unsigned int k_var,
                                     unsigned int l_var) {
  if ((j_var == _c_var) && (k_var == _c_var) && (l_var == _c_var))
    return -12.0 * _A[_qp] + 24.0 * _A[_qp] * _c[_qp];
  else
    return 0.0;
}
