#include "RadiationDefectSource.h"

#include "Material.h"

template<>
InputParameters validParams<RadiationDefectSource>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription("Specifies vacancy or interstitial source created due to radiation");
  MooseEnum defect_type("Vacancy=0 Interstitial", "Vacancy");
  params.addRequiredParam<MooseEnum>("defect_type", defect_type, "Specify the type of defect created due to radiation (vacancy or interstitial)");
  return params;
}
RadiationDefectSource::RadiationDefectSource(const InputParameters & parameters) :
    Kernel(parameters),
    _defect_type(getParam<MooseEnum>("defect_type")),
    _defect_name(_defect_type),
    _defect_increase(getMaterialProperty<Real>(_defect_name + "_increase"))
{
}

Real
RadiationDefectSource::computeQpResidual()
{
  return -_defect_increase[_qp];
}
