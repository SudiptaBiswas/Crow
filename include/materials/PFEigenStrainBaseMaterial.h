#ifndef PFEIGENSTRAINBASEMATERIAL_H
#define PFEIGENSTRAINBASEMATERIAL_H

// #include "LinearElasticMaterial.h"
#include "ComputeEigenstrain.h"
#include "DerivativeMaterialInterface.h"

/**
 * EigenStrainBaseMaterial is a base to construct material kernels that represent
 * different eigenstrain - concentration relationships.
 * It provides place holders for calculating eigenstrain and its 1st and 2nd
 * order derivatives with respect to c, elasticity_tensor and its 1st and 2nd
 * order derivatives wrt c if it is a function of c instead of a constant.
 */
class PFEigenStrainBaseMaterial : public DerivativeMaterialInterface<ComputeEigenstrain>
{
public:
  PFEigenStrainBaseMaterial(const InputParameters & parameters);

protected:
  virtual void computeEigenStrain() = 0;
  virtual RankTwoTensor computeStressFreeStrain();

  const VariableValue & _c;
  const VariableName _c_name;

    std::string _eigenstrain_name;
  MaterialProperty<RankTwoTensor> & _eigenstrain;

  MaterialProperty<RankTwoTensor> & _delastic_strain_dc;
  MaterialProperty<RankTwoTensor> & _d2elastic_strain_dc2;

  // MaterialProperty<ElasticityTensorR4> & _delasticity_tensor_dc;
  // MaterialProperty<ElasticityTensorR4> & _d2elasticity_tensor_dc2;

  std::vector<const VariableValue *> _vals;
  std::vector<VariableName> _v_name;
  unsigned int _ncrys;

  std::vector<MaterialProperty<RankTwoTensor> *> _delastic_strain_dv;
  // std::vector<MaterialProperty<ElasticityTensorR4> *> _delasticity_tensor_dv;
  std::vector<std::vector<MaterialProperty<RankTwoTensor> *> > _d2elastic_strain_dv2;
  // std::vector<std::vector<MaterialProperty<ElasticityTensorR4> *> > _d2elasticity_tensor_dv2;
};

#endif //PFEIGENSTRAINBASEMATERIAL_H
