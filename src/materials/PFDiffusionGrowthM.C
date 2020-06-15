#include "PFDiffusionGrowthM.h"

registerMooseObject("CrowApp", PFDiffusionGrowthM);

template <> InputParameters validParams<PFDiffusionGrowthM>() {
  InputParameters params = validParams<Material>();
  params.addParam<Real>("Dvol", 0.01, "Volumetric diffusion ");
  params.addParam<Real>("Dvap", 0.001, "Vapor Diffusion ");
  params.addParam<Real>("Dsurf", 4, "surface diffusion");
  params.addParam<Real>("Dgb", 0.4, "Grain Boundary diffusion");
  params.addParam<Real>("kappa", 1.0,
                        "The kappa multiplier for the interfacial energy");
  params.addRequiredCoupledVar("rho", "phase field variable");
  params.addRequiredCoupledVar("v", "array of order parameters");

  return params;
}

PFDiffusionGrowthM::PFDiffusionGrowthM(const InputParameters &parameters)
    : Material(parameters), _Dvol(getParam<Real>("Dvol")),
      _Dvap(getParam<Real>("Dvap")), _Dsurf(getParam<Real>("Dsurf")),
      _Dgb(getParam<Real>("Dgb")), _kappa(getParam<Real>("kappa")),

      _rho(coupledValue("rho")), _grad_rho(coupledGradient("rho")),
      _v(coupledValue("v")),

      _D(declareProperty<Real>("D")),
      // _kappa_c(declareProperty<Real>("kappa_c")),
      _dDdc(declareProperty<Real>("dDdc")) {
  // Array of coupled variables is created in the constructor
  _ncrys = coupledComponents(
      "v"); // determine number of grains from the number of names passed in.
  _vals.resize(_ncrys); // Size variable arrays
  _vals_var.resize(_ncrys);

  // Loop through grains and load coupled variables into the arrays
  for (unsigned int i = 0; i < _ncrys; ++i) {
    _vals[i] = &coupledValue("v", i);
    _vals_var[i] = coupled("v", i);
  }
}

void PFDiffusionGrowthM::computeQpProperties() {
  Real SumEtaj = 0.0;
  for (unsigned int i = 0; i < _ncrys; ++i)
    for (unsigned int j = 0; j < _ncrys; ++j)
      if (j != i)
        SumEtaj += (*_vals[i])[_qp] *
                   (*_vals[j])[_qp]; // Sum all other order parameters
  Real c = _rho[_qp];
  c = c > 1.0 ? 1.0 : (c < 0.0 ? 0.0 : c);

  Real phi = c * c * c * (10 - 15 * c + 6 * c * c);
  phi = phi > 1.0 ? 1.0 : (phi < 0.0 ? 0.0 : phi);
  _D[_qp] = _Dvol * phi + _Dvap * (1.0 - phi) + _Dsurf * c * (1 - c) +
            _Dgb * SumEtaj; // + _Dvap*(1 - phi) ;

  Real dphidc = 30.0 * c * c * (1 - 2 * c + c * c);
  _dDdc[_qp] = _Dvol * dphidc - _Dvap * dphidc + _Dsurf * (1.0 - 2.0 * c);

  // _kappa_c[_qp] = _kappa;
}
