#include "SinteringCoefficients.h"
// libMesh includes
#include "libmesh/quadrature.h"

registerMooseObject("CrowApp", SinteringCoefficients);

template <> InputParameters validParams<SinteringCoefficients>() {
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
  params.addParam<Real>("GB_energy", 1.0, "GB Energy in eV/m^2");
  params.addParam<Real>("GBmob0", 0,
                        "Grain boundary mobility prefactor in m^4/(J*s)");
  params.addParam<Real>("Qgbm", 0,
                        "Grain boundary migration activation energy in eV");
  params.addParam<Real>("GBMobility", -1,
                        "GB mobility input in m^4/(J*s), that overrides the "
                        "temperature dependent calculation");
  params.addParam<bool>("anisotropic", false,
                        "GB mobility input in m^4/(J*s), that overrides the "
                        "temperature dependent calculation");
  // params.addRequiredParam<UserObjectName>("gbenergymap",
  // "AnisoGBEnergyUserObject holding the grain boundary energy mapping");
  return params;
}

SinteringCoefficients::SinteringCoefficients(const InputParameters &parameters)
    : Material(parameters), _T(coupledValue("T")),
      _L(declareProperty<Real>("L")), _A(declareProperty<Real>("A")),
      _B(declareProperty<Real>("B")),
      _kappa_c(declareProperty<Real>("kappa_c")),
      _kappa_op(declareProperty<Real>("kappa_op")),
      _int_width(getParam<Real>("int_width")),
      _time_scale(getParam<Real>("time_scale")),
      _length_scale(getParam<Real>("length_scale")),
      _energy_scale(getParam<Real>("energy_scale")),
      _energy_unit(getParam<MooseEnum>("energy_unit")),
      _surface_energy(getParam<Real>("surface_energy")),
      _GB_energy(getParam<Real>("GB_energy")),
      _GBmob0(getParam<Real>("GBmob0")), _Q(getParam<Real>("Qgbm")),
      _GBMobility(getParam<Real>("GBMobility")),
      _JtoeV(6.24150974e18), // Joule to eV conversion
      _kb(8.617343e-5)       // Boltzmann constant in eV/K
{
  if (_GBMobility == -1 && _GBmob0 == 0)
    mooseError(
        "Either a value for GBMobility or for GBmob0 and Q must be provided");
}

void SinteringCoefficients::computeProperties() {
  Real energy_scale = _energy_scale; // Decide energy scale based on energy unit
  if (_energy_unit == 0)
    energy_scale *= _JtoeV;

  const Real GB_energy = _GB_energy / energy_scale * _length_scale *
                         _length_scale; // Non-dimensionalized GB energy
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
    // Energetic parameters
    _kappa_c[_qp] =
        3.0 / 4.0 * (2.0 * surface_energy - GB_energy) * int_width_c;
    // _kappa_c[_qp] =  3.0/4.0 * surface_energy * int_width_c;
    _kappa_op[_qp] = 3.0 / 4.0 * GB_energy * int_width_c;
    _A[_qp] = (12.0 * surface_energy - 7.0 * GB_energy) / int_width_c;
    _B[_qp] = GB_energy / int_width_c;

    // Kinetic parameters
    Real GBmob;
    if (_GBMobility < 0)
      GBmob = GBmob0_c * std::exp(-_Q / (_kb * _T[_qp]));
    else
      GBmob = _GBMobility * _time_scale /
              ((energy_scale * _JtoeV) *
               (_length_scale * _length_scale * _length_scale * _length_scale));
    ; // GBMobility in m^4/(J*s)

    _L[_qp] = 4.0 / 3.0 * GBmob /
              int_width_c; // Non-dimensionalized Allen-Cahn Mobility
  }
}
