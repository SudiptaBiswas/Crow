#include "ACParticleGrowth.h"

registerMooseObject("CrowApp", ACParticleGrowth);

template <> InputParameters validParams<ACParticleGrowth>() {
  InputParameters params = ACBulk<Real>::validParams();
  params.addRequiredCoupledVar(
      "v", "Array of order parameter names except the current one");
  params.addRequiredCoupledVar("c", "phase field variable, particle density");
  return params;
}

ACParticleGrowth::ACParticleGrowth(const InputParameters &parameters)
    : ACBulk<Real>(parameters), _c(coupledValue("c")), _c_var(coupled("c")),
      _L(getMaterialProperty<Real>("mob_name")),
      _B(getMaterialProperty<Real>("B")),
      _ncrys(coupledComponents("v")) // determine number of grains from the
                                     // number of names passed in.  Note this is
                                     // the actual number -1
{
  // Array of coupled variables is created in the constructor
  _vals.resize(_ncrys); // Size variable arrays
  _vals_var.resize(_ncrys);

  // Loop through grains and load coupled variables into the arrays
  for (unsigned int i = 0; i < _ncrys; ++i) {
    _vals[i] = &coupledValue("v", i);
    _vals_var[i] = coupled("v", i);
  }
}

Real ACParticleGrowth::computeDFDOP(PFFunctionType type) {
  Real c = _c[_qp];

  Real SumEtaj = 0.0;
  for (unsigned int i = 0; i < _ncrys; ++i)
    SumEtaj +=
        (*_vals[i])[_qp] * (*_vals[i])[_qp]; // Sum all other order parameters

  // Calcualte either the residual or jacobian of the grain growth free energy
  switch (type) {
  case Residual:
    return 12.0 * _B[_qp] *
           ((1.0 - c) * _u[_qp] - (2.0 - c) * _u[_qp] * _u[_qp] +
            _u[_qp] * (SumEtaj + _u[_qp] * _u[_qp]));

  case Jacobian:
    return 12.0 * _B[_qp] * _phi[_j][_qp] *
           ((1.0 - c) - 2.0 * (2.0 - c) * _u[_qp] + SumEtaj +
            3.0 * _u[_qp] * _u[_qp]);
  }

  mooseError("Invalid type passed in");
}

Real ACParticleGrowth::computeQpOffDiagJacobian(unsigned int jvar) {
  if (jvar == _c_var) {
    Real dDFDc = 12.0 * _B[_qp] * (_u[_qp] * _u[_qp] - _u[_qp]) * _phi[_j][_qp];
    return _L[_qp] * _test[_i][_qp] * dDFDc;
  }
  for (unsigned int i = 0; i < _ncrys; ++i)
    if (jvar == _vals_var[i]) {
      Real dSumEtaj =
          2.0 * (*_vals[i])[_qp] * _phi[_j][_qp]; // Derivative of SumEtaj
      Real dDFDOP = 12.0 * _B[_qp] * _u[_qp] * dSumEtaj;
      return _L[_qp] * _test[_i][_qp] * dDFDOP;
    }

  return 0.0;
}
