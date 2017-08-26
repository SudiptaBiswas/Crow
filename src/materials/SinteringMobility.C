#include "SinteringMobility.h"
// libMesh includes
#include "libmesh/quadrature.h"

template<>
InputParameters validParams<SinteringMobility>()
{
  InputParameters params = validParams<Material>();
  params.addRequiredCoupledVar("c","phase field variable");
  params.addRequiredCoupledVarWithAutoBuild("v", "var_name_base", "op_num", "Array of coupled variables");
  params.addCoupledVar("T", "Temperature variable in Kelvin");
  params.addRequiredParam<Real>("int_width","The interfacial width in the lengthscale of the problem");
  params.addParam<Real>("length_scale", 1.0e-9,"defines the base length scale of the problem in m");
  params.addParam<Real>("time_scale", 1.0e-9, "defines the base time scale of the problem");
  params.addParam<Real>("ls", 1.0e-9,"Surface layer thickness in m");
  params.addParam<Real>("Dvol0", 0.01, "Volumetric diffusion coefficient ");
  params.addParam<Real>("Dvap0", 0.001, "Vapor Diffusion ");
  params.addParam<Real>("Qv", 1.0, "Vacancy migration energy in eV");
  params.addParam<Real>("Qvc", 1.0, "Vacancy migration energy in eV");
  params.addParam<Real>("Vm", 1.25e-28, "Atomic volume in m^3");
  params.addParam<Real>("Dsurf0", 4, "surface diffusion");
  params.addParam<Real>("Dgb0", 0.4, "Grain Boundary diffusion");
  params.addParam<Real>("Qs", 0, "Surface Diffusion activation energy in eV");
  params.addParam<Real>("Qgb", 0, "GB Diffusion activation energy in eV");
  params.addParam<Real>("surfindex", 0.0, "Index for surface diffusion");
  params.addParam<Real>("gbindex", 0.0, "Index for GB diffusion");
  params.addParam<Real>("bulkindex", 1.0, "Index for bulk diffusion");
  params.addParam<Real>("prefactor", 1.0, "prefactor for increasing surface diffusion.");
  return params;
}

SinteringMobility::SinteringMobility(const InputParameters & parameters) :
    Material(parameters),
    _T(coupledValue("T")),
    _c(coupledValue("c")),
    _grad_c(coupledGradient("c")),
    _D(declareProperty<Real>("D")),
    _Dbulk(declareProperty<Real>("Dbulk")),
    _Dsurf(declareProperty<Real>("Dsurf")),
    _Dgb(declareProperty<Real>("Dgb")),
    _dDdc(declareProperty<Real>("dDdc")),
    _M(declareProperty<Real>("M")),
    _dMdc(declareProperty<Real>("dMdc")),
    _A(getMaterialProperty<Real>("A")),
    _B(getMaterialProperty<Real>("B")),
    _time_scale(getParam<Real>("time_scale")),
    _int_width(getParam<Real>("int_width")),
    _length_scale(getParam<Real>("length_scale")),
    _ls(getParam<Real>("ls")),
    _D0(getParam<Real>("Dvol0")),
    _Em(getParam<Real>("Qv")),
    _Dv0(getParam<Real>("Dvap0")),
    _Qvc(getParam<Real>("Qvc")),
    _omega(getParam<Real>("Vm")),
    _Ds0(getParam<Real>("Dsurf0")),
    _Dgb0(getParam<Real>("Dgb0")),
    _Qs(getParam<Real>("Qs")),
    _Qgb(getParam<Real>("Qgb")),
    _surfindex(getParam<Real>("surfindex")),
    _gbindex(getParam<Real>("gbindex")),
    _bulkindex(getParam<Real>("bulkindex")),
    _prefactor(getParam<Real>("prefactor")),
    _JtoeV(6.24150974e18), // Joule to eV conversion
    _kb(8.617343e-5), // Boltzmann constant in eV/K
    _ncrys(coupledComponents("v"))
{
  if (_ncrys == 0)
    mooseError("Model requires op_num > 0");

  _vals.resize(_ncrys);
  _grad_vals.resize(_ncrys);
  for (unsigned int i=0; i < _ncrys; ++i)
  {
    _vals[i] = &coupledValue("v", i);
    _grad_vals[i] = &coupledGradient("v", i);
  }
}

void
SinteringMobility::computeProperties()
{
  const Real D0_c = _D0 * _time_scale / (_length_scale * _length_scale); // Non-dimensionalized Bulk Diffusivity prefactor
  const Real Dv0_c = _Dv0 * _time_scale / (_length_scale * _length_scale); // Non-dimensionalized Bulk Diffusivity prefactor
  const Real Dgb0_c = _Dgb0 * _time_scale / (_length_scale * _length_scale); // Non-dimensionalized GB Diffusivity prefactor
  const Real Ds0_c = _Ds0 * _time_scale / (_length_scale * _length_scale); // Non-dimensionalized Surface Diffusivity prefactor
  const Real omega = _omega / (_length_scale * _length_scale * _length_scale); // omega/kT in m^3/J

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    Real c = _c[_qp];
    c = c>1.0 ? 1.0 : (c<0.0 ? 0.0 : c);
    Real mc = 1.0 - c;
    /* The equilibrium values at a curved surface is higher/lower than the
     * corresponding ones at a flat surface due to Gibbs-Thompson condition.
     * This could affect the sign of the mobility function and/or its derivative,
     * so we must avoid that
     */

    // Compute bulk Diffusivity (bulk diffusion is turned on by default)
    Real Dbulk = D0_c * std::exp(-_Em/(_kb * _T[_qp]));
    Real Dvap = Dv0_c * std::exp(-_Qvc/(_kb * _T[_qp]));
    Real phi = 10.0*c*c*c - 15.0*c*c*c*c + 6.0*c*c*c*c*c; // interpolation function
    phi = phi>1.0 ? 1.0 : (phi<0.0 ? 0.0 : phi);
    Real mult_bulk = 1.0 - phi;
    Real dmult_bulk = -30.0*c*c + 60.0*c*c*c - 30.0*c*c*c*c;

    Real Dgb(0.0);
    if (_gbindex > 0.0) // compute only when GB diffusion is turned on
    {
      Real D_GB = Dgb0_c * std::exp(-_Qgb/(_kb * _T[_qp]));
      for (unsigned int i = 0; i < _ncrys; ++i)
        for (unsigned int j = 0; j < _ncrys; ++j)
        {
          if (i != j)
            Dgb += D_GB * (*_vals[i])[_qp] * (*_vals[j])[_qp];
        }
    }
    // Compute surface diffusivity matrix
    Real Dsurf(0.0);
    Real mult_surf(0.0);
    Real dmult_surf(0.0);
    if (_surfindex > 0.0) // compute only when surface diffusion is turned on
    {
      Dsurf = Ds0_c * std::exp(-_Qs/(_kb * _T[_qp]));
      // mult_surf = (c*mc);
      // dmult_surf = (1 - 2 * c);
      mult_surf = 30 * (c*c*mc*mc);
      dmult_surf = 30 * (2.0 * c * mc * mc - 2.0 * c * c * mc);
    }

    // Compute different mobility tensors and their derivatives
    Real d2F =  12.0 * _A[_qp] * c * c - 12.0 * _A[_qp] * c + 2.0 * (_A[_qp] + _B[_qp]);
    Real Mbulk = Dbulk * phi;
    Real dMbulkdc = -Dbulk * dmult_bulk;
    Real Mvap = Dvap * mult_bulk;
    Real dMvapdc = Dvap * dmult_bulk;
    Real Msurf = Dsurf * mult_surf;
    Real dMsurfdc = Dsurf * dmult_surf;
    // Real omega_kT = _omega / (_kb * _T[_qp])*_JtoeV; // omega/kT in m^3/J
    // Real Mbulk = Dbulk * mult_bulk * omega_kT * _energy_scale[_qp];
    // Real dMbulkdc = Dbulk * dmult_bulk * omega_kT * _energy_scale[_qp];
    // Real Msurf = 2.0/3.0*Dsurf*mult_surf*omega_kT*_energy_scale[_qp]*_ls/(int_width_c*_length_scale);
    // Real dMsurfdc = 2.0/3.0*Dsurf*dmult_surf*omega_kT*_energy_scale[_qp]*_ls/(int_width_c*_length_scale);
    // Real Mgb = Dgb* omega_kT * _energy_scale[_qp];

    // Compute the total mobility tensor and its derivative
    // _Dbulk[_qp] = _bulkindex * Mvap + _bulkindex * Mbulk;
    _Dbulk[_qp] = _bulkindex * Mbulk;
    _Dsurf[_qp] = _surfindex * Msurf;
    _Dgb[_qp] = _gbindex * Dgb;
    _D[_qp] = _prefactor * (_Dbulk[_qp] + _Dgb[_qp] + _Dsurf[_qp]);
    // _dDdc[_qp] = (_bulkindex * dMbulkdc + _bulkindex * dMvapdc + _surfindex * dMsurfdc);
    _dDdc[_qp] = _prefactor * (_bulkindex * dMbulkdc + _surfindex * dMsurfdc);

    // _M[_qp] = _D[_qp] * omega / d2F;
    _M[_qp] = _D[_qp] * omega / (_kb * _T[_qp]);
    // _dMdc[_qp] = _dDdc[_qp] * omega / d2F;
    _dMdc[_qp] = _dDdc[_qp] * omega / (_kb * _T[_qp]);
  }
}
