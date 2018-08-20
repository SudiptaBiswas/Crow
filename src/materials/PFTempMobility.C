#include "PFTempMobility.h"

registerMooseObject("CrowApp", PFTempMobility);

template <> InputParameters validParams<PFTempMobility>() {
  InputParameters params = validParams<Material>();
  params.addParam<Real>("Da", 5.2e-12, "Volumetric diffusion ");
  params.addParam<Real>("Db", 2.6e-10, "Vapor Diffusion ");
  params.addParam<Real>("R", 8.314e-3, "Universal Gas constant");
  params.addParam<Real>("Vm", 6.8e-6, "Molar Volume");
  params.addParam<Real>("kappa", 1.0,
                        "The kappa multiplier for the interfacial energy");
  params.addRequiredCoupledVar("c", "phase field variable");
  params.addCoupledVar("T", "Temperature");
  // params.addRequiredCoupledVar("eta","order parameter");

  return params;
}

PFTempMobility::PFTempMobility(const InputParameters &parameters)
    : Material(parameters), _Da(getParam<Real>("Da")),
      _Db(getParam<Real>("Db")), _R(getParam<Real>("R")),
      _Vm(getParam<Real>("Vm")), _kappa(getParam<Real>("kappa")),
      // _l(getParam<Real>("L")),

      _c(coupledValue("c")), _grad_c(coupledGradient("c")),
      _T(coupledValue("T")),

      _M(declareProperty<Real>("M")),
      //_kappa_op(declareProperty<Real>("kappa_op")),
      _kappa_c(declareProperty<Real>("kappa_c")),
      //_L(declareProperty<Real>("L")),
      _grad_M(declareProperty<RealGradient>("grad_M"))

{}

void PFTempMobility::computeQpProperties() {
  // Real SumEtaj = 0.0;
  // for (unsigned int i = 0; i < _ncrys; ++i)
  // SumEtaj += (*_vals[i])[_qp]*(*_vals[i])[_qp]; //Sum all other order
  // parameters
  {
    Real Ma = (_Da * std::exp(-145.0 / (_R * _T[_qp]))) / (_R * _T[_qp]);
    Real Mb = (_Db * std::exp(-130.0 / (_R * _T[_qp]))) / (_R * _T[_qp]);

    _M[_qp] =
        (_c[_qp] * (1.0 - _c[_qp]) * (_c[_qp] * Ma + (1.0 - _c[_qp]) * Mb)) /
        _Vm;
    _grad_M[_qp] =
        ((1.0 - 2.0 * _c[_qp]) * (_c[_qp] * Ma + (1.0 - _c[_qp]) * Mb) +
         _c[_qp] * (1.0 - _c[_qp]) * (Ma - Mb)) *
        _grad_c[_qp] / _Vm;

    _kappa_c[_qp] = _kappa;
  }
}
