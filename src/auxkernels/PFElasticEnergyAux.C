#include "PFElasticEnergyAux.h"

registerMooseObject("CrowApp", PFElasticEnergyAux);

template<>
InputParameters validParams<PFElasticEnergyAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addParam<std::vector<Real> >("applied_stress_vector", "Applied strain: s11, s22, s33, s23, s13, s12");
  return params;
}

PFElasticEnergyAux::PFElasticEnergyAux( const InputParameters & parameters )
  :AuxKernel(parameters),
   _stress( getMaterialProperty<RankTwoTensor>("stress") ),
   _elastic_strain(getMaterialProperty<RankTwoTensor>("elastic_strain"))
   //_applied_stress_vector(getParam<std::vector<Real> >("applied_stress_vector")),
    //_applied_stress_tensor
{
  //Initialize applied strain tensor from input vector
  //if (_applied_stress_vector.size() == 6)
   // _applied_stress_tensor.fillFromInputVector(_applied_stress_vector);
  //else
   // _applied_stress_tensor.zero();
}

Real
PFElasticEnergyAux::computeValue()
{
  return 0.5*_stress[_qp].doubleContraction(_elastic_strain[_qp]);
  //- _applied_stress.doubleContraction(_elastic_strain[_qp]);
}
