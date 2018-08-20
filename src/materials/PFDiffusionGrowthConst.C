#include "PFDiffusionGrowthConst.h"

registerMooseObject("CrowApp", PFDiffusionGrowthConst);

template <> InputParameters validParams<PFDiffusionGrowthConst>() {
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
  params.addRequiredCoupledVar("rho", "phase field variable");
  // params.addRequiredCoupledVar("eta","order parameter");

  return params;
}

PFDiffusionGrowthConst::PFDiffusionGrowthConst(
    const InputParameters &parameters)
    : Material(parameters), _Dvol(getParam<Real>("Dvol")),
      _Dvap(getParam<Real>("Dvap")), _Dsurf(getParam<Real>("Dsurf")),
      _Dgb(getParam<Real>("Dgb")), _beta(getParam<Real>("beta")),
      _kappa(getParam<Real>("kappa")), _l(getParam<Real>("L")),

      _rho(coupledValue("rho")), _grad_rho(coupledGradient("rho")),
      //_eta(coupledValue("eta")),

      _D(declareProperty<Real>("D")),
      _kappa_op(declareProperty<Real>("kappa_op")),
      _kappa_c(declareProperty<Real>("kappa_c")),
      _L(declareProperty<Real>("L")),
      _grad_D(declareProperty<RealGradient>("grad_D"))

{
  // Array of coupled variables is created in the constructor
  //_ncrys = coupledComponents("eta"); //determine number of grains from the
  // number of names passed in.  Note this is the actual number -1
  //_vals.resize(_ncrys); //Size variable arrays
  //_vals_var.resize(_ncrys);

  // _gamma = 1.5;

  // Loop through grains and load coupled variables into the arrays
  // for (unsigned int i = 0; i < _ncrys; ++i)
  //{
  //  _vals[i] = &coupledValue("eta", i);
  //  _vals_var[i] = coupled("eta", i);
  //}
}

void PFDiffusionGrowthConst::computeQpProperties() {
  // Real SumEtaj = 0.0;
  // for (unsigned int i = 0; i < _ncrys; ++i)
  // SumEtaj += (*_vals[i])[_qp]*(*_vals[i])[_qp]; //Sum all other order
  // parameters
  {
    Real phi = _rho[_qp] * _rho[_qp] * _rho[_qp] *
               (10 - 15 * _rho[_qp] + 6 * _rho[_qp] * _rho[_qp]);
    _D[_qp] =
        _Dvol * phi + _Dvap * (1 - phi) + _Dsurf * _rho[_qp] * (1 - _rho[_qp]);

    RealGradient grad_phi = 30.0 * _rho[_qp] * _rho[_qp] *
                            (1 - 2 * _rho[_qp] + _rho[_qp] * _rho[_qp]) *
                            _grad_rho[_qp];
    _grad_D[_qp] = _Dvol * grad_phi - _Dvap * grad_phi +
                   _Dsurf * (1 - 2.0 * _rho[_qp]) * _grad_rho[_qp];

    //+ _Dgb*SumEtaj;

    _kappa_op[_qp] = _beta;
    _kappa_c[_qp] = _kappa;
    _L[_qp] = -_l;
  }
}
