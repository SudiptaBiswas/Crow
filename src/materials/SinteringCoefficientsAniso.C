#include "SinteringCoefficientsAniso.h"
// libMesh includes
#include "MooseMesh.h"

#include "libmesh/quadrature.h"

registerMooseObject("CrowApp", SinteringCoefficientsAniso);

template <> InputParameters validParams<SinteringCoefficientsAniso>() {
  InputParameters params = validParams<Material>();
  params.addCoupledVar("T", "Temperature variable in Kelvin");
  params.addRequiredParam<Real>(
      "int_width", "The interfacial width in the lengthscale of the problem");
  params.addParam<Real>("length_scale", 1.0e-9,
                        "defines the base length scale of the problem in m");
  params.addParam<Real>("time_scale", 1.0e-9,
                        "defines the base time scale of the problem in s");
  params.addParam<Real>("energy_scale", 1.0e-9,
                        "defines the base energy scale of the problem in eV");
  MooseEnum energy_unit("Joule eV", "eV");
  params.addParam<MooseEnum>(
      "energy_unit", energy_unit,
      "Specify the energy unit for surface and Gb energy.");
  params.addParam<Real>("surface_energy", 1.0, "Surface Energy in eV/m^2");
  params.addParam<Real>("GBmob0", 0,
                        "Grain boundary mobility prefactor in m^4/(J*s)");
  params.addParam<Real>("Qgbm", 0,
                        "Grain boundary migration activation energy in eV");
  params.addParam<Real>("GBMobility", -1,
                        "GB mobility input in m^4/(J*s), that overrides the "
                        "temperature dependent calculation");
  params.addParam<Real>(
      "delta_sigma", 0.1,
      "factor determining inclination dependence of GB energy");
  params.addParam<Real>(
      "delta_mob", 0.1,
      "factor determining inclination dependence of GB mobility");
  // params.addRequiredParam<UserObjectName>(
  //     "gbenergymap",
  //     "AnisoGBEnergyUserObject holding the grain boundary energy mapping");
  params.addParam<bool>("mobility_anisotropy", false,
                        "GB mobility input in m^4/(J*s), that overrides the "
                        "temperature dependent calculation");
  params.addParam<bool>(
      "inclination_anisotropy", false,
      "The GB anisotropy inclination would be considered if true");
  params.addRequiredCoupledVarWithAutoBuild("v", "var_name_base", "op_num",
                                            "Array of coupled variables");

  return params;
}

SinteringCoefficientsAniso::SinteringCoefficientsAniso(
    const InputParameters &parameters)
    : Material(parameters), _mesh_dimension(_mesh.dimension()),
      _T(coupledValue("T")), _delta_sigma(getParam<Real>("delta_sigma")),
      _delta_mob(getParam<Real>("delta_mob")), _L(declareProperty<Real>("L")),
      _A(declareProperty<Real>("A")), _B(declareProperty<Real>("B")),
      _kappa_c(declareProperty<Real>("kappa_c")),
      _kappa_op(declareProperty<Real>("kappa_op")),
      _int_width(getParam<Real>("int_width")),
      _time_scale(getParam<Real>("time_scale")),
      _length_scale(getParam<Real>("length_scale")),
      _energy_scale(getParam<Real>("energy_scale")),
      _energy_unit(getParam<MooseEnum>("energy_unit")),
      _surface_energy(getParam<Real>("surface_energy")),
      _GBmob0(getParam<Real>("GBmob0")), _Q(getParam<Real>("Qgbm")),
      _GBMobility(getParam<Real>("GBMobility")),
      // _aniso_GB_energy(getUserObject<AnisoGBEnergyUserObject>("gbenergymap")),
      _mobility_anisotropy(getParam<bool>("mobility_anisotropy")),
      _inclination_anisotropy(getParam<bool>("inclination_anisotropy")),
      _JtoeV(6.24150974e18), // Joule to eV conversion
      _kb(8.617343e-5),      // Boltzmann constant in eV/K
      _op_num(coupledComponents("v")) {
  if (_GBMobility == -1 && _GBmob0 == 0)
    mooseError(
        "Either a value for GBMobility or for GBmob0 and Q must be provided");

  _vals.resize(_op_num);
  _grad_vals.resize(_op_num);
  for (unsigned int i = 0; i < _op_num; ++i) {
    _vals[i] = &coupledValue("v", i);
    _grad_vals[i] = &coupledGradient("v", i);
  }
}

void SinteringCoefficientsAniso::computeProperties() {
  Real energy_scale = _energy_scale; // Decide energy scale based on energy unit
  if (_energy_unit == 0)
    energy_scale *= _JtoeV;

  // Real GB_energy = _aniso_GB_energy.getWeightedEnergy(_current_elem->id());

  Real GB_energy = 1.5 * (_JtoeV * _length_scale * _length_scale /
                          energy_scale); // Non-dimensionalized GB energy
  const Real surface_energy =
      _surface_energy / energy_scale * _length_scale * _length_scale;
  const Real int_width_c = _int_width; // The interfacial width is input in the
                                       // length scale of the problem, so no
                                       // conversion is necessary
  const Real GBmob0_c =
      _GBmob0 * _time_scale /
      ((energy_scale * _JtoeV) *
       (_length_scale * _length_scale * _length_scale *
        _length_scale)); // Convert to lengthscale^4/(eV*timescale);

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp) {
    // Kinetic parameters
    Real GBmob;
    if (_GBMobility < 0)
      GBmob = GBmob0_c * std::exp(-_Q / (_kb * _T[_qp]));
    else
      GBmob = _GBMobility * _time_scale /
              ((energy_scale * _JtoeV) *
               (_length_scale * _length_scale * _length_scale * _length_scale));
    ; // GBMobility in m^4/(J*s)

    Real L_iso = 4.0 / 3.0 * GBmob /
                 int_width_c; // Non-dimensionalized Allen-Cahn Mobility

    if (_mobility_anisotropy) {
      Real sum_L = 0.0;
      Real sum_sigma = 0.0;
      Real Val = 0.0;
      Real sum_val = 0.0;
      Real f_sigma = 1.0;
      Real f_mob = 1.0;
      // Real sigma = 0.0

      for (unsigned int m = 0; m < _op_num - 1; ++m)
        for (unsigned int n = m + 1; n < _op_num; ++n) // m<n
        {
          if (_inclination_anisotropy) {
            if (_mesh_dimension == 3)
              mooseError("This material doesn't support inclination dependence "
                         "for 3D for now!");

            Real phi_ave = libMesh::pi * n / (2.0 * _op_num);
            Real sin_phi = std::sin(2.0 * phi_ave);
            Real cos_phi = std::cos(2.0 * phi_ave);

            Real a = (*_grad_vals[m])[_qp](0) - (*_grad_vals[n])[_qp](0);
            Real b = (*_grad_vals[m])[_qp](1) - (*_grad_vals[n])[_qp](1);
            Real ab = a * a + b * b + 1.0e-7; // for the sake of numerical
                                              // convergence, the smaller the
                                              // more accurate, but more
                                              // difficult to converge
            Real cos_2phi =
                cos_phi * (a * a - b * b) / ab + sin_phi * 2.0 * a * b / ab;
            Real cos_4phi = 2.0 * cos_2phi * cos_2phi - 1.0;

            f_sigma = 1.0 + _delta_sigma * cos_4phi;
            f_mob = 1.0 + _delta_mob * cos_4phi;
          }

          Val = (100000.0 * ((*_vals[m])[_qp]) * ((*_vals[m])[_qp]) + 0.01) *
                (100000.0 * ((*_vals[n])[_qp]) * ((*_vals[n])[_qp]) + 0.01);
          // Val = ((*_vals[m])[_qp]) * ((*_vals[m])[_qp]) * ((*_vals[n])[_qp])
          // * ((*_vals[n])[_qp]);

          sum_val += Val;
          // Following comes from substituting Eq. (36c) from the paper into
          // (36b)
          sum_L += Val * f_mob * L_iso;
          // sum_sigma += Val * f_sigma * GB_energy;
        }

      _L[_qp] = sum_L / sum_val;
      //  GB_energy = sum_sigma / sum_val;
    } else
      _L[_qp] = L_iso;
    // }
    // Energetic parameters
    _kappa_c[_qp] =
        3.0 / 4.0 * (2.0 * surface_energy - GB_energy) * int_width_c;
    // _kappa_c[_qp] =  3.0/4.0 * surface_energy * int_width_c;
    _kappa_op[_qp] = 3.0 / 4.0 * GB_energy * int_width_c;
    _A[_qp] = (12.0 * surface_energy - 7.0 * GB_energy) / int_width_c;
    _B[_qp] = GB_energy / int_width_c;
  }
}
