#ifndef SINTERINGCOEFFICIENTSANISO_H
#define SINTERINGCOEFFICIENTSANISO_H

#include "Material.h"
// #include "AnisoGBEnergyUserObject.h"

// Forward Declarations
class SinteringCoefficientsAniso;

template <> InputParameters validParams<SinteringCoefficientsAniso>();

/**
 * Calculated vacancy and interstitial properties for a given material.  No
 * defaults. The temperature must be in Kelvin
 */
class SinteringCoefficientsAniso : public Material {
public:
  SinteringCoefficientsAniso(const InputParameters &parameters);

protected:
  virtual void computeProperties();

  // private:
  const unsigned int _mesh_dimension;

  const VariableValue &_T;
  std::vector<const VariableValue *> _vals;
  std::vector<const VariableGradient *> _grad_vals;

  const Real _delta_sigma;
  const Real _delta_mob;

  MaterialProperty<Real> &_L;
  MaterialProperty<Real> &_A;
  MaterialProperty<Real> &_B;
  MaterialProperty<Real> &_kappa_c;
  MaterialProperty<Real> &_kappa_op;
  // MaterialProperty<Real> & _sum_val;
  // MaterialProperty<Real> & _f_mob;

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
  // const AnisoGBEnergyUserObject &_aniso_GB_energy;
  bool _mobility_anisotropy;
  bool _inclination_anisotropy;

  // Constants
  const Real _JtoeV;
  const Real _kb;

  unsigned int _op_num;
};

#endif // SINTERINGCOEFFICIENTSANISO_H
