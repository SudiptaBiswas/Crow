#include "ThermalVariation.h"
// #include "AddV.h"
// libMesh includes
#include "libmesh/quadrature.h"

registerMooseObject("CrowApp", ThermalVariation);

template <> InputParameters validParams<ThermalVariation>() {
  InputParameters params = validParams<Material>();
  params.addCoupledVar("eta", 0.0, "Order Parameter");
  params.addCoupledVar("v", "Array of coupled variables");
  params.addParam<Real>("length_scale", 1.0e-8, "Lengthscale of model");
  params.addParam<Real>(
      "Gas_conductivity", 0.152,
      "Thermal conductivity in the pore in W/m-K, defaults to He");
  params.addParam<Real>("GB_conductivity", 0.1,
                        "conductivity in the GB for Paul & Karthik's model");
  params.addParam<Real>(
      "Bulk_conductivity", 4.5,
      "Bulk conductivity override (for Paul & Karthik's model)");
  params.addParam<unsigned int>("op_num", 0, "number of grains");
  params.addParam<std::string>("var_name_base", "base for variable names");
  return params;
}

ThermalVariation::ThermalVariation(const InputParameters &parameters)
    : Material(parameters), _has_v(isCoupled("v")),
      _length_scale(getParam<Real>("length_scale")),
      _Gas_conductivity(getParam<Real>("Gas_conductivity")),
      _GB_cond(getParam<Real>("GB_conductivity")),
      _ko(getParam<Real>("Bulk_conductivity")), _eta(coupledValue("eta")),
      _thermal_conductivity(declareProperty<Real>("thermal_conductivity")) {
  if (_has_v) {
    // Assign grain order parameters
    _n = coupledComponents("v");
    _vals.resize(_n);

    for (unsigned int i = 0; i < _n; ++i)
      _vals[i] = &coupledValue("v", i);
  } else
    _n = 0;
}

void ThermalVariation::computeProperties() {
  for (_qp = 0; _qp < _qrule->n_points(); ++_qp) {
    Real local_cond = 0.0; // The output thermal conductivity
    Real UO2_cond;
    Real Gas_cond = _Gas_conductivity; // Thermal cond

    UO2_cond = computeBulkThermalConductivity();

    // GB-defining Parameters

    Real bnds = 1.0;
    if (_has_v) {
      bnds = 0.0;
      for (unsigned int i = 0; i < _n; ++i)
        bnds += (*_vals[i])[_qp] * (*_vals[i])[_qp];
    }

    // Define the local conductivity (Karthik & Paul's model)

    Real p12 = 0;
    if (_has_v)
      for (unsigned int i = 0; i < _n; ++i)
        for (unsigned int j = i + 1; j < _n; ++j)
          p12 += (*_vals[i])[_qp] * (*_vals[j])[_qp];

    if (bnds > 0.90)
      local_cond = UO2_cond;

    if (bnds <= 0.90) {
      if (p12 < 0.001)
        local_cond = UO2_cond * (1.0 - _eta[_qp] * _eta[_qp]) +
                     Gas_cond * _eta[_qp] * _eta[_qp];
      if (p12 > 0.001)
        local_cond = UO2_cond;
      if (p12 > 0.01)
        local_cond = _GB_cond;
    }

    Real e = _eta[_qp];
    if (e > 0.1)
      local_cond = Gas_cond;

    if (local_cond <= 0.0)
      local_cond = Gas_cond;

    // Rescale the conductivity
    _thermal_conductivity[_qp] =
        local_cond * _length_scale; // Thermal conductivity in W/(10nm-K)
  }
}

Real ThermalVariation::computeBulkThermalConductivity() { return _ko; }
