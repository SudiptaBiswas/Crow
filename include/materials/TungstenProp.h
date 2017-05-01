/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef TungstenProp_H
#define TungstenProp_H

#include "Material.h"
#include "DerivativeMaterialInterface.h"
#include "Function.h"

//Forward Declarations
class TungstenProp;

template<>
InputParameters validParams<TungstenProp>();

/**
 * This class is here to get the force and torque acting on a grain
 */
class TungstenProp :
    public DerivativeMaterialInterface<Material>
{
public:
  TungstenProp(const InputParameters & parameters);

  virtual void computeQpProperties();

protected:

  const VariableValue & _T;

  Real _length_scale;
  Real _mass_scale;
  Real _time_scale;

  MaterialProperty<Real> & _thermal_conductivity;
  MaterialProperty<Real> & _specific_heat;
  MaterialProperty<Real> & _density;
};

#endif //TungstenProp_H
