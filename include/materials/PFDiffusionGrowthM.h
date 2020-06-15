#ifndef PFDIFFUSIONGROWTHM_H
#define PFDIFFUSIONGROWTHM_H

#include "Material.h"

//Forward Declarations
class PFDiffusionGrowthM;

template<>
InputParameters validParams<PFDiffusionGrowthM>();

class PFDiffusionGrowthM : public Material
{
public:
  PFDiffusionGrowthM(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

private:
  std::vector<const VariableValue *> _vals;
  std::vector<unsigned int> _vals_var;

  Real _Dvol;
  Real _Dvap;
  Real _Dsurf;
  Real _Dgb;

  Real _kappa;

  const VariableValue & _rho;
  const VariableGradient & _grad_rho;
  const VariableValue & _v;

  MaterialProperty<Real> & _D;
  // MaterialProperty<Real> & _kappa_c;
  MaterialProperty<Real> & _dDdc;

  unsigned int _ncrys;
};

#endif //PFDIFFUSIONGROWTH_H
