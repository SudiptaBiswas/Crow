#include "PFDiffusionGrowth1.h"

registerMooseObject("CrowApp", PFDiffusionGrowth1);

template <> InputParameters validParams<PFDiffusionGrowth1>() {
  InputParameters params = validParams<Material>();
  params.addParam<Real>("Dvol", 0.01, "Volumetric diffusion ");
  params.addParam<Real>("Dvap", 0.001, "Vapor Diffusion ");
  params.addParam<Real>("Dsurf", 4, "surface diffusion");
  params.addParam<Real>("Dgb", 0.4, "Grain Boundary diffusion");
  params.addParam<Real>("beta", 1.0,
                        "The beta multiplier for the interfacial energy");
  params.addParam<Real>("kappa", 1.0,
                        "The kappa multiplier for the interfacial energy");
  params.addParam<Real>("L", 1.0, "The Allen-cahn multiplier");
  params.addCoupledVar("eta", 0.0, "sum of order parameters");
  params.addRequiredCoupledVar("c", "phase field variable");

  return params;
}

PFDiffusionGrowth1::PFDiffusionGrowth1(const InputParameters &parameters)
    : Material(parameters), _Dvol(getParam<Real>("Dvol")),
      _Dvap(getParam<Real>("Dvap")), _Dsurf(getParam<Real>("Dsurf")),
      _Dgb(getParam<Real>("Dgb")), _beta(getParam<Real>("beta")),
      _kappa(getParam<Real>("kappa")), _l(getParam<Real>("L")),

      _c(coupledValue("c")), _grad_c(coupledGradient("c")),
      _sumetaj(coupledValue("eta")),

      _D(declareProperty<Real>("D")),
      _kappa_op(declareProperty<Real>("kappa_op")), // equivalent to beta,
                                                    // notation changed as per
                                                    // kernel requirement
      _kappa_c(declareProperty<Real>("kappa_c")),
      _L(declareProperty<Real>("L")),
      _grad_D(declareProperty<RealGradient>("grad_D"))

{}

void PFDiffusionGrowth1::computeQpProperties() {

  Real phi =
      _c[_qp] * _c[_qp] * _c[_qp] * (10 - 15 * _c[_qp] + 6 * _c[_qp] * _c[_qp]);
  _D[_qp] = _Dvol * phi + _Dvap * (1 - phi) + _Dsurf * _c[_qp] * (1 - _c[_qp]) +
            _Dgb * _sumetaj[_qp];

  RealGradient grad_phi = 30.0 * _c[_qp] * _c[_qp] *
                          (1 - 2 * _c[_qp] + _c[_qp] * _c[_qp]) * _grad_c[_qp];
  _grad_D[_qp] = _Dvol * grad_phi - _Dvap * grad_phi +
                 _Dsurf * (1 - 2.0 * _c[_qp]) * _grad_c[_qp];

  _kappa_op[_qp] = _beta;
  _kappa_c[_qp] = _kappa;
  _L[_qp] = -_l;
}
