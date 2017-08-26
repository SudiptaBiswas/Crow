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
  params.addParam<Real>("prefactor", 1.0, "prefactor for increasing surface diffusion.");
  return params;
}

SinteringMtrxMobility::SinteringMtrxMobility(const InputParameters & parameters) :
    Material(parameters),
    _T(coupledValue("T")),
    _c(coupledValue("c")),
    _grad_c(coupledGradient("c")),
    // _Dbulk(declareProperty<RealTensorValue>("Dbulk")),
    // _Dsurf(declareProperty<RealTensorValue>("Dsurf")),
    // _Dgb(declareProperty<RealTensorValue>("Dgb")),
    _D(declareProperty<RealTensorValue>("D")),
    _M(declareProperty<RealTensorValue>("M")),
    _dDdc(declareProperty<RealTensorValue>("dDdc")),
    _dMdc(declareProperty<RealTensorValue>("dMdc")),
    _detD(declareProperty<Real>("det_D")),
    _detM(declareProperty<Real>("det_M`")),
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
    // Real Dbulk = 0.01;
    // Real Dvap = 0.001;
    Real phi = 10.0*c*c*c - 15.0*c*c*c*c + 6.0*c*c*c*c*c; // interpolation function
    phi = phi>1.0 ? 1.0 : (phi<0.0 ? 0.0 : phi);
    Real mult_bulk = 1.0 - phi;
    Real dmult_bulk = -30.0*c*c + 60.0*c*c*c - 30.0*c*c*c*c;

    RealTensorValue Dgb(0.0);
    Real D_GB(0.0);
    if (_gbindex > 0.0) // compute only when GB diffusion is turned on
    {
      D_GB = Dgb0_c * std::exp(-_Qgb/(_kb * _T[_qp]));
      // D_GB = 0.4;
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

      RealTensorValue Ts(0.0);
      RealTensorValue dTs(0.0);
      for (unsigned int a = 0; a < 3; ++a)
        for (unsigned int b = 0; b < 3; ++b)
        {
          /* Adding small positive values on the diagonal makes the projection tensor
           * non-negative everywhere in the domain
           */
          Ts(a,b) = (1.0+1.0e-3) * I(a,b) - ns(a) * ns(b);
          // std::cout << "Ts_"<< a << b << "= " << Ts(a,b) << ", ns = " << ns << ".\n";
          dTs(a,b) = - 2.0 * dns(a) * ns(b);
        }

      Dsurf = Ds0_c * std::exp(-_Qs/(_kb * _T[_qp]));
      // Dsurf = 4.0;
      // mult_surf = (c * mc) * Ts;
      mult_surf = 30 * (c * c * mc * mc) * Ts;
      // dmult_surf = (1 - 2.0*c) * Ts + (c * mc) * dTs;
      dmult_surf = 30 * (2.0 * c * mc * mc - 2.0 * c * c * mc) * Ts + 30 * c * c * mc * mc * dTs;
    }

    Real d2F =  12.0 * _A[_qp] * c * c - 12.0 * _A[_qp] * c + 2.0 * (_A[_qp] + _B[_qp]);
    // Compute different mobility tensors and their derivatives
    RealTensorValue Mbulk = Dbulk * mult_bulk * I;
    RealTensorValue dMbulkdc = Dbulk * dmult_bulk * I;
    RealTensorValue Mvap = Dvap * mult_bulk * I;
    RealTensorValue dMvapdc = Dvap * dmult_bulk * I;
    RealTensorValue Msurf = Dsurf * mult_surf;
    //std::cout << "Dsurf = " << Dsurf << " and \n";
    //std::cout << "ns = " << Ts << " and \n";
    //std::cout << "mult = " << mult_surf <<" and \n";
    //std::cout << "Msurf = " << Msurf << "\n";
    RealTensorValue dMsurfdc = _prefactor * Dsurf * dmult_surf;
    // RealTensorValue Mgb = Dgb * omega / d2F;

    // Compute the total mobility tensor and its derivative
    // _D[_qp] = (_bulkindex * Mbulk + _gbindex * Dgb + _surfindex * Msurf);
    // _dDdc[_qp] = (_bulkindex * dMbulkdc + _surfindex * dMsurfdc);
    // _D[_qp] = (_bulkindex * Mbulk + _bulkindex * Mvap + _gbindex * Dgb + _surfindex * Msurf);
    // _dDdc[_qp] = (_bulkindex * dMbulkdc + _bulkindex * dMvapdc + _surfindex * dMsurfdc);
    // _Dbulk[_qp] = _bulkindex * Mbulk;
    // _Dsurf[_qp] = _surfindex * Msurf;
    // _Dgb[_qp] = _gbindex * Dgb;
    // _D[_qp] = _prefactor * (_Dbulk[_qp] + _Dgb[_qp] + _Dsurf[_qp]);
    _D[_qp] = _prefactor * (_bulkindex * Mbulk + _gbindex * Dgb + _surfindex * Msurf);
    // _dDdc[_qp] = (_bulkindex * dMbulkdc + _bulkindex * dMvapdc + _surfindex * dMsurfdc);
    _dDdc[_qp] = _prefactor * (_bulkindex * dMbulkdc + _surfindex * dMsurfdc);
    _M[_qp] = _D[_qp] * omega / (_kb * _T[_qp]);
    // _dMdc[_qp] = _dDdc[_qp] * omega / d2F;
    _dMdc[_qp] = _dDdc[_qp] * omega / (_kb * _T[_qp]);
    // _M[_qp] = (_bulkindex * Mbulk  + _gbindex * Dgb + _surfindex * Msurf) * omega / d2F;
    // _dMdc[_qp] = (_bulkindex * dMbulkdc + _surfindex * dMsurfdc) * omega / d2F;
  // Compute the mobility determinant
    _detD[_qp] = _D[_qp].det(); // to make sure it is non-negative anywhere in the domain
    _detM[_qp] = _M[_qp].det(); // to make sure it is non-negative anywhere in the domain
  }
}
