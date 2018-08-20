#ifndef PFEIGENSTRAINMATERIAL_H
#define PFEIGENSTRAINMATERIAL_H

#include "PFEigenStrainBaseMaterial.h"

class PFEigenStrainMaterial;

template <> InputParameters validParams<PFEigenStrainMaterial>();
/**
 * EigenStrainBaseMaterial is a base to construct material kernels that
 * represent different eigenstrain - concentration relationships. It provides
 * place holders for calculating eigenstrain and its 1st and 2nd order
 * derivatives with respect to c, elasticity_tensor and its 1st and 2nd order
 * derivatives wrt c if it is a function of c instead of a constant.
 */
class PFEigenStrainMaterial : public PFEigenStrainBaseMaterial {
public:
  PFEigenStrainMaterial(const InputParameters &parameters);

protected:
  virtual void computeEigenStrain();
  virtual void computeQpElasticityTensor();

  std::vector<const VariableValue *> _vals;
  std::vector<VariableName> _v_name;
  unsigned int _ncrys;

  std::vector<MaterialProperty<RankTwoTensor> *> _delastic_strain_dv;
  // std::vector<MaterialProperty<ElasticityTensorR4> *> _delasticity_tensor_dv;
  std::vector<std::vector<MaterialProperty<RankTwoTensor> *>>
      _d2elastic_strain_dv2;
  // std::vector<std::vector<MaterialProperty<ElasticityTensorR4> *> >
  // _d2elasticity_tensor_dv2;

private:
  Real _e_v;
  Real _epsilon0;
  Real _c0;
};

#endif // PFEIGENSTRAINMATERIAL1_H
