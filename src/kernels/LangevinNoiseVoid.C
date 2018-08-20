#include "LangevinNoiseVoid.h"
#include "MooseRandom.h"

registerMooseObject("CrowApp", LangevinNoiseVoid);

template <> InputParameters validParams<LangevinNoiseVoid>() {
  InputParameters params = validParams<Kernel>();
  params.addParam<Real>("amplitude", 1.0, "Amplitude"); // per sqrt(time)");
  params.addParam<Real>(
      "Pcasc", 0.0, "Probability of cascade occurance."); // per sqrt(time)");
  params.addParam<std::string>("multiplier", "Material property to multiply "
                                             "the random numbers with "
                                             "(defaults to 1.0 if omitted)");
  params.addRequiredCoupledVar("eta", "order parameter for void");
  params.addParam<Real>("min", 0.0,
                        "Lower bound of the randomly generated values");
  params.addParam<Real>("max", 1.0,
                        "Upper bound of the randomly generated values");
  return params;
}
LangevinNoiseVoid::LangevinNoiseVoid(const InputParameters &parameters)
    : Kernel(parameters), _amplitude(getParam<Real>("amplitude")),
      _Pcasc(getParam<Real>("Pcasc")),
      _multiplier_prop(
          parameters.isParamValid("multiplier")
              ? &getMaterialProperty<Real>(getParam<std::string>("multiplier"))
              : NULL),
      _eta(coupledValue("eta")), _min(getParam<Real>("min")),
      _max(getParam<Real>("max")), _range(_max - _min)

{}

void LangevinNoiseVoid::residualSetup() {
  unsigned int rseed = _t_step;
  MooseRandom::seed(rseed);
}

Real LangevinNoiseVoid::computeQpResidual() {

  Real R2 = MooseRandom::rand();
  // Between 0 and range
  R2 *= _range;
  // Between min and max
  R2 += _min;

  Real R1 = MooseRandom::rand();
  // Between 0 and range
  R1 *= _range;
  // Between min and max
  R1 += _min;

  Real e = _eta[_qp];

  // if ( e <= 0.8 && R1< _Pcasc)
  if (e <= 0.8)
    return -_test[_i][_qp] * R2 * _amplitude *
           (_multiplier_prop == NULL ? 1.0 : (*_multiplier_prop)[_qp]);

  return 0.0;
}
