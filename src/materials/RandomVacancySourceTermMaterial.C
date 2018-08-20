#include "MooseRandom.h"
#include "RandomVacancySourceTermMaterial.h"

registerMooseObject("CrowApp", RandomVacancySourceTermMaterial);

template <> InputParameters validParams<RandomVacancySourceTermMaterial>() {
  InputParameters params = validParams<Material>();
  params.addParam<Real>("min", 0.0,
                        "Lower bound of the randomly generated values");
  params.addParam<Real>("max", 1.0,
                        "Upper bound of the randomly generated values");
  params.addParam<unsigned int>("seed", 0,
                                "Seed value for the random number generator");
  // params.addParam<Real>("Pcasc", 0.5 ,"Probability of cascade occurance");
  // params.addParam<Real>("Vg", 0.5 ,"Maximum increase in vacancy
  // concentration");
  return params;
}

RandomVacancySourceTermMaterial::RandomVacancySourceTermMaterial(
    const InputParameters &parameters)
    : Material(parameters), _min(getParam<Real>("min")),
      _max(getParam<Real>("max")), _range(_max - _min),

      _R(declareProperty<Real>("R"))

{
  MooseRandom::seed(getParam<unsigned int>("seed"));
}

void RandomVacancySourceTermMaterial::computeQpProperties() {

  // Random number between 0 and 1

  Real rand_num = MooseRandom::rand();

  // Between 0 and range
  rand_num *= _range;

  // Between min and max
  rand_num += _min;

  _R[_qp] = rand_num;
}

// Real
// RandomVacancySourceTermMaterial::computeQpJacobian()
//{
// return 0;
//}
//
