#include "Mobility.h"
#include "MooseVariable.h"

template<>
InputParameters validParams<Mobility>()
{
  InputParameters params = validParams<Material>();
  params.addClassDescription("Phase field parameters for polynomial free energy for single component systems");
  params.addCoupledVar("T", "Temperature variable in Kelvin");
  params.addRequiredCoupledVar("c", "Concentration");
  params.addRequiredParam<Real>("int_width", "The interfacial width of void surface in the lengthscale of the problem");
  params.addParam<Real>("length_scale", 1.0e-9, "defines the base length scale of the problem in m");
  params.addParam<Real>("time_scale", 1.0e-9, "defines the base time scale of the problem");
  params.addRequiredParam<Real>("D0", "Diffusivity prefactor for vacancies in m^2/s");
  params.addRequiredParam<Real>("Em", "Migration energy in eV");
  params.addRequiredParam<Real>("Ef", "Formation energy in eV");
  params.addRequiredParam<Real>("surface_energy", "Surface energy in J/m2");
  return params;
}

Mobility::Mobility(const InputParameters & parameters) :
    Material(parameters),
    _c(coupledValue("c")),
    _c_name(getVar("c", 0)->name()),
    _T(coupledValue("T")),
    _M(declareProperty<Real>("M_"+_c_name)),
    _grad_M(declareProperty<RealGradient>("grad_M_"+_c_name)),
    _kappa(declareProperty<Real>("kappa_"+_c_name)),
    _c_eq(declareProperty<Real>(_c_name+"_eq")),
    _Qstar(declareProperty<Real>("Qstar")),
    _D(declareProperty<Real>("D_"+_c_name)),
    _int_width(getParam<Real>("int_width")),
    _length_scale(getParam<Real>("length_scale")),
    _time_scale(getParam<Real>("time_scale")),
    _D0(getParam<Real>("D0")),
    _Ef(getParam<Real>("Ef")),
    _surface_energy(getParam<Real>("surface_energy")),
    _JtoeV(6.24150974e18), // joule to eV conversion
    _kb(8.617343e-5) // Boltzmann constant in eV/K
{
}

void
Mobility::computeQpProperties()
{
  // Convert mobility from m^2/s to the length and time scale
  Real D0_c = _D0*_time_scale/(_length_scale*_length_scale);

  Real kbT = _kb*_T[_qp];

  //Compute equilibrium concentration and diffusivity
  _c_eq[_qp] = std::exp(-_Ef/kbT);
  //_D[_qp] = D0_c*std::exp(-_Em/kbT);

  // Convert surface energy from J/m2 to eV/length_scale
  Real surf_energy = _surface_energy*_JtoeV*_length_scale*_length_scale;

  // Set interfacial parameter and energy barrier
  _kappa[_qp] = surf_energy*_int_width;
//_W[_qp] = surf_energy/( 2.0*_int_width*KN );
  //_M[_qp] = KN/Co*(_D[_qp]*_int_width/surf_energy);
  _M[_qp] = D0_c*_c[_qp]/kbT;
  _grad_M[_qp] = D0_c/kbT;

  _Qstar[_qp] = -4.0; // eV
}
