#include "VacancySourceTermKernel.h"

registerMooseObject("CrowApp", VacancySourceTermKernel);

template <> InputParameters validParams<VacancySourceTermKernel>() {
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("eta", "order parameter for void");
  // params.addCoupledVar("R1", "Random no. generation");
  // params.addCoupledVar("R2", "Random no. generation");
  params.addParam<std::string>("Rand_num", "R", "variable for random number");
  // params.addParam<Real>("Pcasc", 0.5 ,"Probability of cascade occurance");
  params.addParam<Real>("Vg", 0.5, "Maximum increase in vacancy concentration");
  return params;
}

VacancySourceTermKernel::VacancySourceTermKernel(
    const InputParameters &parameters)
    : Kernel(parameters), _eta(coupledValue("eta")),
      //_R1(coupledValue("R1")),
      //_R2(coupledValue("R2")),
      _rand_num(getParam<std::string>("Rand_num")),
      _R(getMaterialProperty<Real>(_rand_num)),
      // _Pcasc(getParam<Real>("Pcasc")),
      _Vg(getParam<Real>("Vg"))

{}

Real VacancySourceTermKernel::computeQpResidual() {
  Real e = _eta[_qp];
  // Real R1 = _R1[_qp];

  // if ( e <= 0.8 && R1<_Pcasc)
  if (e <= 0.8)
    return _R[_qp] * _Vg * _test[_i][_qp];

  return 0.0;
}

// Real
// VacancySourceTermKernel::computeQpJacobian()
//{
// return 0;
//}
//
