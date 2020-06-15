#ifndef PFDIFFUSIONGROWTHM1_H
#define PFDIFFUSIONGROWTHM1_H

#include "Material.h"

//Forward Declarations
class PFDiffusionGrowthM1;

template<>
InputParameters validParams<PFDiffusionGrowthM1>();

class PFDiffusionGrowthM1 : public Material
{
public:
  PFDiffusionGrowthM1(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

private:
  std::vector<const VariableValue *> _vals;
  std::vector<unsigned int> _vals_var;

  //Real _Dvol;
  Real _Dvap;
  Real _Dsurf;
  Real _Dgb;

  Real _kappa;

  const VariableValue & _Dvol;
  const VariableValue & _rho;
  const VariableGradient & _grad_rho;
  const VariableValue & _v;

  MaterialProperty<Real> & _D;
  // MaterialProperty<Real> & _kappa_c;
  MaterialProperty<Real> & _dDdc;

  unsigned int _ncrys;
};

#endif //PFDIFFUSIONGROWTHM1_H
