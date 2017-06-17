#include "PFEigenStrainBaseMaterial.h"

template<>
InputParameters validParams<PFEigenStrainBaseMaterial>()
{
  InputParameters params = validParams<ComputeEigenstrain>();
  params.addRequiredCoupledVar("c", "Concentration");
  params.addCoupledVar("v", "order parameters");
  return params;
}

PFEigenStrainBaseMaterial::PFEigenStrainBaseMaterial(const InputParameters & parameters) :
    DerivativeMaterialInterface<ComputeEigenstrain>(parameters),

    _c(coupledValue("c")),
    _c_name(getVar("c", 0)->name()),

    _eigenstrain_name(_base_name + "eigenstrain"),
    _eigenstrain(declareProperty<RankTwoTensor>(_eigenstrain_name)),

    // the derivatives of elastic strain w.r.t c are provided here
    _delastic_strain_dc(declarePropertyDerivative<RankTwoTensor>(_base_name + "elastic_strain", _c_name)),
    _d2elastic_strain_dc2(declarePropertyDerivative<RankTwoTensor>(_base_name + "elastic_strain", _c_name, _c_name))

    // _delasticity_tensor_dc(declarePropertyDerivative<ElasticityTensorR4>(_elasticity_tensor_name, _c_name)),
    // _d2elasticity_tensor_dc2(declarePropertyDerivative<ElasticityTensorR4>(_elasticity_tensor_name, _c_name, _c_name))
{
  _ncrys = coupledComponents("v");
  _vals.resize(_ncrys);
  _v_name.resize(_ncrys);
  _delastic_strain_dv.resize(_ncrys);
  _d2elastic_strain_dv2.resize(_ncrys);
  // _delasticity_tensor_dv.resize(_ncrys);
  // _d2elasticity_tensor_dv2.resize(_ncrys);

  for (unsigned int i=0; i < _ncrys; ++i)
  {
    _vals[i] = &coupledValue("v", i);
    _v_name[i] = getVar("v", i)->name();

  //}

  //for (unsigned int i=0; i < _ncrys; ++i)
  //{
    // the derivatives of elastic strain w.r.t v are provided here
    _delastic_strain_dv[i] = &declarePropertyDerivative<RankTwoTensor>(_base_name + "elastic_strain", _v_name[i]);
    // _delasticity_tensor_dv[i] = &declarePropertyDerivative<ElasticityTensorR4>(_elasticity_tensor_name, _v_name[i]);

    _d2elastic_strain_dv2[i].resize(_ncrys);
    // _d2elasticity_tensor_dv2[i].resize(_ncrys);

  }
    for (unsigned int i=0; i < _ncrys; ++i)
    {
      for (unsigned int j=i; j < _ncrys; ++j)
      {
	_d2elastic_strain_dv2[i][j] = _d2elastic_strain_dv2[j][i] = &declarePropertyDerivative<RankTwoTensor>(_base_name + "elastic_strain", _v_name[i], _v_name[j]);
	// _d2elasticity_tensor_dv2[i][j] = _d2elasticity_tensor_dv2[j][i] = &declarePropertyDerivative<ElasticityTensorR4>(_elasticity_tensor_name, _v_name[i], _v_name[j]);
      }
    }
}

RankTwoTensor PFEigenStrainBaseMaterial::computeStressFreeStrain()
{
  RankTwoTensor stress_free_strain = computeStressFreeStrain();

  computeEigenStrain();

  stress_free_strain -= _eigenstrain[_qp];

  return stress_free_strain;
}
