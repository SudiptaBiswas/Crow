#ifndef RADIATIONDEFECTSOURCE_H
#define RADIATIONDEFECTSOURCE_H

#include "Kernel.h"

//Forward Declarations
class RadiationDefectSource;

template<>
InputParameters validParams<RadiationDefectSource>();

/**
 * Kernel for Vacancy or interstitial source term
 */
class RadiationDefectSource : public Kernel
{
public:
  RadiationDefectSource(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();

private:
  /// Type of defect created due to radiation (vacancy or interstitial)
  const MooseEnum & _defect_type;
  std::string _defect_name;

  /// Material property providing defect incease due to radiation
  const MaterialProperty<Real> & _defect_increase;
};

#endif //RADIATIONDEFECTSOURCE_H
