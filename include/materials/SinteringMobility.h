#ifndef SINTERINGMOBILITY_H
#define SINTERINGMOBILITY_H

#include "Material.h"

//Forward Declarations
class SinteringMobility;

template<>
InputParameters validParams<SinteringMobility>();

/**
 * Calculated vacancy and interstitial properties for a given material.  No defaults.
 * The temperature must be in Kelvin
 */
class SinteringMobility : public Material
{
public:
  SinteringMobility(const InputParameters & parameters);

protected:
  virtual void computeProperties();

private:
  const VariableValue & _T;
  std::vector<const VariableValue *> _vals;
  std::vector<const VariableGradient *> _grad_vals;
  const VariableValue & _c;
  const VariableGradient & _grad_c;

  MaterialProperty<Real> & _D;
  MaterialProperty<Real> & _Dbulk;
  MaterialProperty<Real> & _Dsurf;
  MaterialProperty<Real> & _Dgb;
  MaterialProperty<Real> & _dDdc;
  MaterialProperty<Real> & _M;
  MaterialProperty<Real> & _dMdc;
  // MaterialProperty<Real> & _L;
  // MaterialProperty<Real> & _kappa_c;
  // MaterialProperty<Real> & _kappa_op;
  const MaterialProperty<Real> & _A;
  const MaterialProperty<Real> & _B;
  // MaterialProperty<Real> & _time_scale;
  // MaterialProperty<Real> & _energy_scale;

  Real _time_scale;
  Real _energy_scale;

  Real _int_width;
  Real _length_scale;
  Real _ls;
  Real _D0;
  Real _Em;
  Real _Dv0;
  Real _Qvc;
  // Real _GB_energy;
  // Real _surface_energy;
  Real _GBmob0;
  Real _Q;
  Real _omega;
  Real _Ds0;
  Real _Dgb0;
  Real _Qs;
  Real _Qgb;
  Real _surfindex;
  Real _gbindex;
  Real _bulkindex;
  Real _GBMobility;

  // Constants
  const Real _JtoeV;
  const Real _kb;
  unsigned int _ncrys;
};

#endif //SINTERINGMOBILITY_H
