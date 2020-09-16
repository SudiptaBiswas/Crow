#include "ConservedLangevinNoiseVoidSource.h"

registerMooseObject("CrowApp", ConservedLangevinNoiseVoidSource);

InputParameters ConservedLangevinNoiseVoidSource::validParams() {
  InputParameters params = LangevinNoise::validParams();
  params.addRequiredParam<UserObjectName>(
      "noise", "ConservativeNoise userobject that produces the random numbers");
  params.addRequiredCoupledVar("eta", "order parameter for void");
  return params;
}
ConservedLangevinNoiseVoidSource::ConservedLangevinNoiseVoidSource(
    const InputParameters &parameters)
    : LangevinNoise(parameters),
      _noise(getUserObject<ConservedNoiseInterface>("noise")),
      _eta(coupledValue("eta")) {}

Real ConservedLangevinNoiseVoidSource::computeQpResidual() {
  Real e = _eta[_qp];

  if (e <= 0.8)
    return -_test[_i][_qp] * _noise.getQpValue(_current_elem->id(), _qp) *
           _amplitude * _multiplier_prop[_qp];

  return 0.0;
}
