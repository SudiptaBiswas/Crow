#include "VacancyAnnihilationKernel.h"

registerMooseObject("CrowApp", VacancyAnnihilationKernel);

template <> InputParameters validParams<VacancyAnnihilationKernel>() {
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("v", "Array of coupled order parameters");
  // params.addCoupledVar("c", "Concentration field");
  params.addParam<Real>("ceq", "Equilibrium concentration");
  params.addParam<std::string>("Svgb", "S",
                               "Efficiency of void nucleation/annihilation");
  return params;
}

VacancyAnnihilationKernel::VacancyAnnihilationKernel(
    const InputParameters &parameters)
    : Kernel(parameters), _Svgb_name(getParam<std::string>("Svgb")),
      _Svgb(getMaterialProperty<Real>(_Svgb_name)), _ceq(getParam<Real>("ceq"))
//_c(coupledValue("c"))

{
  // Array of coupled variables is created in the constructor
  _ncrys = coupledComponents("v"); // determine number of grains from the number
                                   // of names passed in.  Note this is the
                                   // actual number -1
  _vals.resize(_ncrys);            // Size variable arrays
  _vals_var.resize(_ncrys);

  // _gamma = 1.5;

  // Loop through grains and load coupled variables into the arrays
  for (unsigned int i = 0; i < _ncrys; ++i) {
    _vals[i] = &coupledValue("v", i);
    _vals_var[i] = coupled("v", i);
  }
}

Real VacancyAnnihilationKernel::computeQpResidual() {
  Real SumEtaj = 0.0;
  for (unsigned int i = 0; i < _ncrys; ++i)
    // for (unsigned int j = 0; j < _ncrys; ++j)
    SumEtaj +=
        (*_vals[i])[_qp] * (*_vals[i])[_qp]; // Sum all other order parameters

  // SumEtaj = (*_vals[i])[_qp];

  return _Svgb[_qp] * (1 - SumEtaj) * (_u[_qp] - _ceq) * _test[_i][_qp];
}

Real VacancyAnnihilationKernel::computeQpJacobian() {
  Real SumEtaj = 0.0;
  for (unsigned int i = 0; i < _ncrys; ++i)
    // for (unsigned int j = 0; j < _ncrys; ++j)
    SumEtaj +=
        (*_vals[i])[_qp] * (*_vals[i])[_qp]; // Sum all other order parameters
  // SumEtaj = (*_vals[i])[_qp];

  return _test[_i][_qp] * _Svgb[_qp] * (1 - SumEtaj) * _phi[_j][_qp];
}
