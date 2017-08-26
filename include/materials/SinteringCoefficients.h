#ifndef SINTERINGCOEFFICIENTS_H
#define SINTERINGCOEFFICIENTS_H

#include "Material.h"

//Forward Declarations
class SinteringCoefficients;

template<>
InputParameters validParams<SinteringCoefficients>();

/**
 * Calculated vacancy and interstitial properties for a given material.  No defaults.
 * The temperature must be in Kelvin
 */
class SinteringCoefficients : public Material
{
public:
  SinteringCoefficients(const InputParameters & parameters);

protected:
  virtual void computeProperties();

private:
  const VariableValue & _T;

  MaterialProperty<Real> & _L;
  MaterialProperty<Real> & _A;
  MaterialProperty<Real> & _B;
  MaterialProperty<Real> & _kappa_c;
  MaterialProperty<Real> & _kappa_op;

  Real _int_width;
  Real _time_scale;
  Real _length_scale;
  Real _energy_scale;

  const MooseEnum _energy_unit;
  Real _surface_energy;
  Real _GB_energy;

  Real _GBmob0;
  Real _Q;
  Real _GBMobility;

  // Constants
  const Real _JtoeV;
  const Real _kb;
};

#endif //SINTERINGCOEFFICIENTS_H
