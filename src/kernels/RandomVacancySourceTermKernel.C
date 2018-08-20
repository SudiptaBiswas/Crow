#include "MooseRandom.h"
#include "RandomVacancySourceTermKernel.h"

registerMooseObject("CrowApp", RandomVacancySourceTermKernel);

template <> InputParameters validParams<RandomVacancySourceTermKernel>() {
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("eta", "order parameter for void");
  params.addParam<Real>("min", 0.0,
                        "Lower bound of the randomly generated values");
  params.addParam<Real>("max", 1.0,
                        "Upper bound of the randomly generated values");
  params.addParam<unsigned int>("seed", 0,
                                "Seed value for the random number generator");
  // params.addParam<Real>("Pcasc", 0.5 ,"Probability of cascade occurance");
  params.addParam<Real>("Vg", 0.5, "Maximum increase in vacancy concentration");
  return params;
}

RandomVacancySourceTermKernel::RandomVacancySourceTermKernel(
    const InputParameters &parameters)
    : Kernel(parameters), _eta(coupledValue("eta")),
      _min(getParam<Real>("min")), _max(getParam<Real>("max")),
      // _Pcasc(getParam<Real>("Pcasc")),
      _Vg(getParam<Real>("Vg")), _range(_max - _min)

{}

Real RandomVacancySourceTermKernel::computeQpResidual() {
  Real e = _eta[_qp];

  // Random number between 0 and 1

  // for (unsigned int qp = 0; qp < _qrule->n_points(); qp++)

  Real R2 = MooseRandom::rand();

  // Between 0 and range
  R2 *= _range;

  // Between min and max
  R2 += _min;

  // Real R1 = _R1[_qp];

  // if ( e <= 0.8 && R1<_Pcasc)
  if (e <= 0.8)
    return -R2 * _Vg * _test[_i][_qp];

  return 0.0;
}

// Real
// RandomVacancySourceTermKernel::computeQpJacobian()
//{
// return 0;
//}
//
