#ifndef PFDiffusionGrowth_H
#define PFDiffusionGrowth_H

#include "Material.h"

//Forward Declarations
class PFDiffusionGrowth;

template<>
InputParameters validParams<PFDiffusionGrowth>();

class PFDiffusionGrowth : public Material
{
public:
  PFDiffusionGrowth(const std::string & name,
             InputParameters parameters);

protected:
  virtual void computeQpProperties();

private:
  std::vector<VariableValue *> _vals;
  std::vector<unsigned int> _vals_var;

  Real _Dvol;
  Real _Dvap;
  Real _Dsurf;
  Real _Dgb;
  
  Real _beta;
  Real _kappa;
  Real _l;

  VariableValue & _rho;
  VariableValue & _eta;

  MaterialProperty<Real> & _D;
  MaterialProperty<Real> & _beta_e;
  MaterialProperty<Real> & _kappa_c;
  MaterialProperty<Real> & _l_e;
  MaterialProperty<RealGradient> & _grad_D;
  unsigned int _ncrys;

};

#endif //PFDiffusionGrowth_H



