#include "PFParticleGrowth.h"
//#include "AddV.h"
registerMooseObject("CrowApp", PFParticleGrowth);

template <> InputParameters validParams<PFParticleGrowth>() {
  InputParameters params = validParams<Material>();
  params.addParam<Real>("beta", 1.0,
                        "The beta multiplier for the interfacial energy");
  params.addParam<Real>("L", 1.0, "The Allen-cahn multiplier");

  return params;
}

PFParticleGrowth::PFParticleGrowth(const InputParameters &parameters)
    : Material(parameters), _beta(getParam<Real>("beta")),
      _l(getParam<Real>("L")),

      _kappa_op(declareProperty<Real>("kappa_op")),
      _L(declareProperty<Real>("L"))

{}

void PFParticleGrowth::computeQpProperties() {
  _kappa_op[_qp] = _beta;
  _L[_qp] = -_l;
}
