#include "SinteringMtrxMobility.h"
// libMesh includes
#include "libmesh/quadrature.h"

template<>
InputParameters validParams<SinteringMtrxMobility>()
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
  params.addRequiredParam<Real>("Qv", "Bulk diffusion activation energy in eV");
  params.addRequiredParam<Real>("Qvc", "Vacancy migration energy in eV");
  params.addParam<Real>("GBmob0", 0, "Grain boundary mobility prefactor in m^4/(J*s)");
  params.addParam<Real>("Qgbm", 0, "Grain boundary migration activation energy in eV");
  params.addParam<Real>("Vm", 1.25e-28, "Atomic volume in m^3");
  params.addParam<Real>("Dsurf0", 4, "surface diffusion");
  params.addParam<Real>("Dgb0", 0.4, "Grain Boundary diffusion");
  params.addParam<Real>("Qs", 0, "Surface Diffusion activation energy in eV");
  params.addParam<Real>("Qgb", 0, "GB Diffusion activation energy in eV");
  params.addParam<Real>("surfindex", 0.0, "Index for surface diffusion");
  params.addParam<Real>("gbindex", 0.0, "Index for GB diffusion");
  params.addParam<Real>("bulkindex", 1.0, "Index for bulk diffusion");
  params.addParam<MaterialPropertyName>("A", "A", "The co-efficient used for free energy");
  params.addParam<MaterialPropertyName>("B", "B", "The co-efficient used for free energy");
  params.addParam<Real>("GBMobility", -1, "GB mobility input in m^4/(J*s), that overrides the temperature dependent calculation");
  return params;
}

SinteringMtrxMobility::SinteringMtrxMobility(const InputParameters & parameters) :
    Material(parameters),
    _T(coupledValue("T")),
    _c(coupledValue("c")),
    _grad_c(coupledGradient("c")),
    _D(declareProperty<RealTensorValue>("D")),
    _dDdc(declareProperty<RealTensorValue>("dDdc")),
    _M(declareProperty<RealTensorValue>("M")),
    _dMdc(declareProperty<RealTensorValue>("dMdc")),
    // _L(declareProperty<Real>("L")),
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
    _GBmob0(getParam<Real>("GBmob0")),
    _Q(getParam<Real>("Qgbm")),
    _omega(getParam<Real>("Vm")),
    _Ds0(getParam<Real>("Dsurf0")),
    _Dgb0(getParam<Real>("Dgb0")),
    _Qs(getParam<Real>("Qs")),
    _Qgb(getParam<Real>("Qgb")),
    _surfindex(getParam<Real>("surfindex")),
    _gbindex(getParam<Real>("gbindex")),
    _bulkindex(getParam<Real>("bulkindex")),
    _GBMobility(getParam<Real>("GBMobility")),
    _JtoeV(6.24150974e18), // Joule to eV conversion
    _kb(8.617343e-5), // Boltzmann constant in eV/K
    _ncrys(coupledComponents("v"))
{
  if (_GBMobility == -1 && _GBmob0 == 0)
    mooseError("Either a value for GBMobility or for GBmob0 and Q must be provided");

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
SinteringMtrxMobility::computeProperties()
{
  RealTensorValue I(1.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,1.0);
  /* the model parameters will be non-dimensionalized for convenience and consistency
  * in calculating the different residuals (Rc and Rw). However, the physical values
  * of the model parameters can be obtained by converting them back to their physical
  * dimensions using the length, time, and energy scales
  */
  // const Real energy_scale = _GB_energy/_length_scale; // energy density scale in J/m^3
  const Real int_width_c = _int_width; // The interfacial width is input in the length scale of the problem, so no conversion is necessary
  // const Real GB_energy = _GB_energy/(energy_scale*_length_scale); // Non-dimensionalized GB energy
  // const Real GB_energy = _GB_energy * _JtoeV * _length_scale*_length_scale;
  // const Real surface_energy = _surface_energy * _JtoeV * _length_scale*_length_scale;
  // const Real surface_energy = _surface_energy/(energy_scale*_length_scale); //Non-dimensionalized surface energy
  // _time_scale = (_length_scale * _length_scale)/(GBmob * _GB_energy); // time scale in s
  const Real D0_c = _D0 * _time_scale / (_length_scale * _length_scale); // Non-dimensionalized Bulk Diffusivity prefactor
  const Real Dv0_c = _Dv0 * _time_scale / (_length_scale * _length_scale); // Non-dimensionalized Bulk Diffusivity prefactor
  const Real Dgb0_c = _Dgb0 * _time_scale / (_length_scale * _length_scale); // Non-dimensionalized GB Diffusivity prefactor
  const Real Ds0_c = _Ds0 * _time_scale / (_length_scale * _length_scale); // Non-dimensionalized Surface Diffusivity prefactor
  const Real GBmob0_c = _GBmob0 * _time_scale / (_JtoeV * (_length_scale*_length_scale*_length_scale*_length_scale)); // Convert to lengthscale^4/(eV*timescale);
  const Real omega = _omega / (_length_scale * _length_scale * _length_scale); // omega/kT in m^3/J

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    // Energetic parameters
    // _kappa_c[_qp] =  3.0/4.0 * (2.0 * surface_energy - GB_energy) * int_width_c;
    // _kappa_c[_qp] =  3.0/4.0 * surface_energy * int_width_c;
    // _kappa_op[_qp] = 3.0/4.0* GB_energy * int_width_c;
    // _A[_qp] = (12.0 * surface_energy - 7.0 * GB_energy) / int_width_c;
    // _B[_qp] = GB_energy / int_width_c;

    // Kinetic parameters
    Real GBmob;
    if (_GBMobility < 0)
      GBmob = GBmob0_c * std::exp(-_Q / (_kb * _T[_qp]));
    else
      GBmob = _GBMobility * _time_scale / (_JtoeV * (_length_scale*_length_scale*_length_scale*_length_scale));; // GBMobility in m^4/(J*s)

    // _L[_qp] = 4.0/3.0 * GBmob / int_width_c; // Non-dimensionalized Allen-Cahn Mobility

    // Real GB_M = GBmob * _time_scale * energy_scale /_length_scale; // Non-dimensionalized GB Mobility

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

    RealTensorValue Dgb(0.0);
    Real D_GB(0.0);
    if (_gbindex > 0.0) // compute only when GB diffusion is turned on
    {
      D_GB = Dgb0_c * std::exp(-_Qgb/(_kb * _T[_qp]));
      for (unsigned int i = 0; i < _ncrys; ++i)
        for (unsigned int j = 0; j < _ncrys; ++j)
        {
          if (i != j)
          {
            RealGradient ngb = (*_grad_vals[i])[_qp] - (*_grad_vals[j])[_qp];
            if (ngb.norm() > 1.0e-10)
              ngb /= ngb.norm();
            else
              ngb = 0.0;

            RealTensorValue Tgb;

            for (unsigned int a = 0; a < 3; ++a)
              for (unsigned int b = 0; b < 3; ++b)
                Tgb(a,b) = I(a,b) - ngb(a) * ngb(b);

            Dgb += D_GB * (*_vals[i])[_qp] * (*_vals[j])[_qp] * Tgb;
          }
        }
    }
    // Compute surface diffusivity matrix
    // RealTensorValue Ts(0.0);
    Real Dsurf(0.0);
    RealTensorValue mult_surf(0.0);
    RealTensorValue dmult_surf(0.0);
    if (_surfindex > 0.0) // compute only when surface diffusion is turned on
    {
      RealGradient ns(0), dns(0);

      if (_grad_c[_qp].norm() > 1.0e-10)
        ns = _grad_c[_qp] / _grad_c[_qp].norm();

      RealTensorValue Ts;
      RealTensorValue dTs;
      for (unsigned int a = 0; a < 3; ++a)
        for (unsigned int b = 0; b < 3; ++b)
        {
          /* Adding small positive values on the diagonal makes the projection tensor
           * non-negative everywhere in the domain
           */
          Ts(a,b) = (1.0+1.0e-3) * I(a,b) - ns(a) * ns(b);
          dTs(a,b) = - 2.0 * dns(a) * ns(b);
        }

      Dsurf = Ds0_c * std::exp(-_Qs/(_kb * _T[_qp]));
      mult_surf = (c * mc) * Ts;
      dmult_surf = (1 - 2.0*c) * Ts + (c * mc) * dTs;
    }

    Real d2F =  12.0 * _A[_qp] * c * c - 12.0 * _A[_qp] * c + 2.0 * (_A[_qp] + _B[_qp]);
    // Compute different mobility tensors and their derivatives
    RealTensorValue Mbulk = Dbulk * mult_bulk * I;
    RealTensorValue dMbulkdc = Dbulk * dmult_bulk * I;
    RealTensorValue Mvap = Dvap * mult_bulk * I;
    RealTensorValue dMvapdc = Dvap * dmult_bulk * I;
    RealTensorValue Msurf = Dsurf * mult_surf;
    RealTensorValue dMsurfdc = Dsurf * dmult_surf;
    // RealTensorValue Mgb = Dgb * omega / d2F;

    // Compute the total mobility tensor and its derivative
    _D[_qp] = (_bulkindex * Mbulk + _bulkindex * Mvap + _gbindex * Dgb + _surfindex * Msurf);
    _dDdc[_qp] = (_bulkindex * dMbulkdc + _bulkindex * dMvapdc + _surfindex * dMsurfdc);
    _M[_qp] = (_bulkindex * Mbulk  + _gbindex * Dgb + _surfindex * Msurf) * omega / d2F;
    _dMdc[_qp] = (_bulkindex * dMbulkdc + _surfindex * dMsurfdc) * omega / d2F;
  }
  // Compute the mobility determinant
  // _detM[_qp] = _M[_qp].det(); // to make sure it is non-negative anywhere in the domain
}
