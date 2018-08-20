#include "PFEigenStrainMaterial.h"
//#include "AddV.h"

registerMooseObject("CrowApp", PFEigenStrainMaterial);

template <> InputParameters validParams<PFEigenStrainMaterial>() {
  InputParameters params = validParams<PFEigenStrainBaseMaterial>();
  params.addCoupledVar("v", "order parameters");
  params.addParam<Real>("e_v", "lattice mismatch co-eff");
  params.addRequiredParam<Real>("epsilon0", "Initial eigen strain value");
  params.addParam<Real>("c0", 0.0, "Initial concentration value");
  params.addRequiredCoupledVar("c", "Concentration");

  return params;
}

PFEigenStrainMaterial::PFEigenStrainMaterial(const InputParameters &parameters)
    : PFEigenStrainBaseMaterial(parameters), _e_v(getParam<Real>("e_v")),
      _epsilon0(getParam<Real>("epsilon0")), _c0(getParam<Real>("c0"))

{
  _ncrys = coupledComponents("v");
  _vals.resize(_ncrys);
  _v_name.resize(_ncrys);
  _delastic_strain_dv.resize(_ncrys);
  _d2elastic_strain_dv2.resize(_ncrys);
  // _delasticity_tensor_dv.resize(_ncrys);
  // _d2elasticity_tensor_dv2.resize(_ncrys);

  for (unsigned int i = 0; i < _ncrys; ++i) {
    _vals[i] = &coupledValue("v", i);
    _v_name[i] = getVar("v", i)->name();

    // the derivatives of elastic strain w.r.t v are provided here
    _delastic_strain_dv[i] = &declarePropertyDerivative<RankTwoTensor>(
        _base_name + "elastic_strain", _v_name[i]);
    // _delasticity_tensor_dv[i] =
    // &declarePropertyDerivative<ElasticityTensorR4>(_elasticity_tensor_name,
    // _v_name[i]);

    _d2elastic_strain_dv2[i].resize(_ncrys);
    // _d2elasticity_tensor_dv2[i].resize(_ncrys);
  }
  for (unsigned int i = 0; i < _ncrys; ++i) {
    for (unsigned int j = i; j < _ncrys; ++j) {
      _d2elastic_strain_dv2[i][j] = _d2elastic_strain_dv2[j][i] =
          &declarePropertyDerivative<RankTwoTensor>(
              _base_name + "elastic_strain", _v_name[i], _v_name[j]);
      // _d2elasticity_tensor_dv2[i][j] = _d2elasticity_tensor_dv2[j][i] =
      // &declarePropertyDerivative<ElasticityTensorR4>(_elasticity_tensor_name,
      // _v_name[i], _v_name[j]);
    }
  }
}

void PFEigenStrainMaterial::computeEigenStrain() {
  Real sumeta = 0.0;
  for (unsigned int i = 0; i < _ncrys; ++i)
    sumeta += (*_vals[i])[_qp] * (*_vals[i])[_qp];

  _eigenstrain[_qp].zero();
  _eigenstrain[_qp].addIa(_epsilon0 * (_c[_qp] - _c0) + (_e_v * sumeta));

  // first derivative w.r.t. c
  _delastic_strain_dc[_qp].zero();
  _delastic_strain_dc[_qp].addIa(
      -_epsilon0); // delastic_strain/dc = -deigenstrain/dc

  // second derivative w.r.t. c (vanishes)
  _d2elastic_strain_dc2[_qp].zero();

  //_eigenstrain[_qp].addIa(_e_v*sumeta);

  // first derivative w.r.t. v
  for (unsigned int i = 0; i < _ncrys; ++i) {
    (*_delastic_strain_dv[i])[_qp].zero();
    (*_delastic_strain_dv[i])[_qp].addIa(-2.0 * _e_v * (*_vals[i])[_qp]);

    // second derivative w.r.t. v
    for (unsigned int j = 0; j < _ncrys; ++j) {
      (*_d2elastic_strain_dv2[i][j])[_qp].zero();
      (*_d2elastic_strain_dv2[i][j])[_qp].addIa(-2.0 * _e_v);
    }
  }
}

void PFEigenStrainMaterial::computeQpElasticityTensor() {
  // _Jacobian_mult[_qp] = _elasticity_tensor[_qp] = _Cijkl;

  // the elasticity tensor is independent of c
  // _delasticity_tensor_dc[_qp].zero();
  // _d2elasticity_tensor_dc2[_qp].zero();
  //
  // // the elasticity tensor is independent of v
  // for (unsigned int i = 0; i < _ncrys; ++i)
  // {
  //  (*_delasticity_tensor_dv[i])[_qp].zero();
  //  //(*_d2elasticity_tensor_dv2[i])[_qp].zero();
  //
  //   for (unsigned int j=0; j < _ncrys; ++j)
  //    (*_d2elasticity_tensor_dv2[i][j])[_qp].zero();
  //  }
}
