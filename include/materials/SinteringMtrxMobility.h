#ifndef SINTERINGMTRXMOBILITY_H
#define SINTERINGMTRXMOBILITY_H

#include "Material.h"

//Forward Declarations
class SinteringMtrxMobility;

template<>
InputParameters validParams<SinteringMtrxMobility>();

/**
 * Calculated vacancy and interstitial properties for a given material.  No defaults.
 * The temperature must be in Kelvin
 */
class SinteringMtrxMobility : public Material
{
public:
  SinteringMtrxMobility(const InputParameters & parameters);

protected:
  virtual void computeProperties();

private:
  const VariableValue & _T;
  std::vector<const VariableValue *> _vals;
  std::vector<const VariableGradient *> _grad_vals;
  const VariableValue & _c;
  const VariableGradient & _grad_c;

  // MaterialProperty<RealTensorValue> & _Dbulk;
  // MaterialProperty<RealTensorValue> & _Dsurf;
  // MaterialProperty<RealTensorValue> & _Dgb;
  MaterialProperty<RealTensorValue> & _D;
  MaterialProperty<RealTensorValue> & _M;
  MaterialProperty<RealTensorValue> & _dDdc;
  MaterialProperty<RealTensorValue> & _dMdc;
  MaterialProperty<Real> & _detD;
  MaterialProperty<Real> & _detM;
  // MaterialProperty<RealTensorValue> & _M;
  // MaterialProperty<RealTensorValue> & _dMdc;
  // MaterialProperty<Real> & _L;
  // MaterialProperty<Real> & _kappa_c;
  // MaterialProperty<Real> & _kappa_op;
  const MaterialProperty<Real> & _A;
  const MaterialProperty<Real> & _B;
  Real _time_scale;
  Real _energy_scale;

  Real _int_width;
  Real _length_scale;
  Real _ls;
  Real _D0;
  Real _Em;
  Real _Dv0;
  Real _Qvc;
  Real _omega;
  Real _Ds0;
  Real _Dgb0;
  Real _Qs;
  Real _Qgb;
  Real _surfindex;
  Real _gbindex;
  Real _bulkindex;
  Real _prefactor;

  // Constants
  const Real _JtoeV;
  const Real _kb;
  unsigned int _ncrys;
};

#endif //SINTERINGMTRXMOBILITY_H
