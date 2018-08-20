#include "PFDiffusionGrowthMtrx.h"

registerMooseObject("CrowApp", PFDiffusionGrowthMtrx);

template <> InputParameters validParams<PFDiffusionGrowthMtrx>() {
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

PFDiffusionGrowthMtrx::PFDiffusionGrowthMtrx(const InputParameters &parameters)
    : Material(parameters), _Dvol(getParam<Real>("Dvol")),
      _Dvap(getParam<Real>("Dvap")), _Dsurf(getParam<Real>("Dsurf")),
      _Dgb(getParam<Real>("Dgb")), _kappa(getParam<Real>("kappa")),

      _rho(coupledValue("rho")), _grad_rho(coupledGradient("rho")),
      _v(coupledValue("v")),

      _D(declareProperty<RealTensorValue>("D")),
      // _kappa_c(declareProperty<Real>("kappa_c")),
      _dDdc(declareProperty<RealTensorValue>("dDdc")) {
  // Array of coupled variables is created in the constructor
  _ncrys = coupledComponents(
      "v"); // determine number of grains from the number of names passed in.
  _vals.resize(_ncrys); // Size variable arrays
  _vals_var.resize(_ncrys);
  _grad_vals.resize(_ncrys);

  // Loop through grains and load coupled variables into the arrays
  for (unsigned int i = 0; i < _ncrys; ++i) {
    _vals[i] = &coupledValue("v", i);
    _vals_var[i] = coupled("v", i);
    _grad_vals[i] = &coupledGradient("v", i);
  }
}

void PFDiffusionGrowthMtrx::computeQpProperties() {
  RealTensorValue I(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0);
  RealTensorValue SumEtaj(0.0);
  for (unsigned int i = 0; i < _ncrys; ++i)
    for (unsigned int j = 0; j < _ncrys; ++j)
      if (j != i) {
        RealGradient ngb = (*_grad_vals[i])[_qp] - (*_grad_vals[j])[_qp];
        if (ngb.norm() > 1.0e-10)
          ngb /= ngb.norm();
        else
          ngb = 0.0;

        RealTensorValue Tgb;

        for (unsigned int a = 0; a < 3; ++a)
          for (unsigned int b = 0; b < 3; ++b)
            Tgb(a, b) = I(a, b) - ngb(a) * ngb(b);

        SumEtaj += (*_vals[i])[_qp] * (*_vals[j])[_qp] *
                   Tgb; // Sum all other order parameters
      }

  Real c = _rho[_qp];
  c = c > 1.0 ? 1.0 : (c < 0.0 ? 0.0 : c);

  Real phi = c * c * c * (10 - 15 * c + 6 * c * c);
  phi = phi > 1.0 ? 1.0 : (phi < 0.0 ? 0.0 : phi);

  RealTensorValue mult_surf(0.0);
  RealTensorValue dmult_surf(0.0);
  RealGradient ns(0), dns(0);

  if (_grad_rho[_qp].norm() > 1.0e-10)
    ns = _grad_rho[_qp] / _grad_rho[_qp].norm();

  RealTensorValue Ts;
  RealTensorValue dTs;
  for (unsigned int a = 0; a < 3; ++a)
    for (unsigned int b = 0; b < 3; ++b) {
      /* Adding small positive values on the diagonal makes the projection
       * tensor non-negative everywhere in the domain
       */
      Ts(a, b) = (1.0 + 1.0e-3) * I(a, b) - ns(a) * ns(b);
      dTs(a, b) = -2.0 * dns(a) * ns(b);
    }

  mult_surf = c * (1 - c) * Ts;
  dmult_surf = (1 - 2.0 * c) * Ts + c * (1 - c) * dTs;

  _D[_qp] = _Dvol * phi * I + _Dvap * (1.0 - phi) * I + _Dsurf * mult_surf +
            _Dgb * SumEtaj; // + _Dvap*(1 - phi) ;

  Real dphidc = 30.0 * c * c * (1 - 2 * c + c * c);
  _dDdc[_qp] = _Dvol * dphidc * I - _Dvap * dphidc * I + _Dsurf * dmult_surf;

  // _kappa_c[_qp] = _kappa;
}
