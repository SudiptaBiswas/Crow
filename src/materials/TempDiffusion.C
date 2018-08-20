#include "TempDiffusion.h"

registerMooseObject("CrowApp", TempDiffusion);

template <> InputParameters validParams<TempDiffusion>() {
  InputParameters params = validParams<Material>();
  params.addParam<Real>("Dv", 0.01, "Volumetric diffusion ");
  params.addParam<Real>("kb", 8.6173324e-5, "Boltzman Constant in eV/K ");
  params.addParam<Real>("T", 1276, "Equilibrium Tempurature ");
  params.addParam<Real>("kappa", 1.0,
                        "The kappa multiplier for the interfacial energy");
  params.addRequiredCoupledVar("c", "phase field variable");
  return params;
}

TempDiffusion::TempDiffusion(const InputParameters &parameters)
    : Material(parameters), _Dv(getParam<Real>("Dv")),
      _kb(getParam<Real>("kb")), _T(getParam<Real>("T")),
      _kappa(getParam<Real>("kappa")),

      _c(coupledValue("c")), _grad_c(coupledGradient("c")),

      _D(declareProperty<Real>("D")),
      _grad_D(declareProperty<RealGradient>("grad_D")),
      _kappa_c(declareProperty<Real>("kappa_c"))

{}

void TempDiffusion::computeQpProperties() {

  _D[_qp] = (_Dv * _c[_qp]) / (_kb * _T);

  _grad_D[_qp] = (_Dv) / (_kb * _T) * _grad_c[_qp];

  _kappa_c[_qp] = _kappa;
}
