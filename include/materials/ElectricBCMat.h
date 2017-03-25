/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef ELECTRICBCMAT_H
#define ELECTRICBCMAT_H

#include "Material.h"
#include "DerivativeMaterialInterface.h"
#include "Function.h"

//Forward Declarations
class ElectricBCMat;

template<>
InputParameters validParams<ElectricBCMat>();

/**
 * This class is here to get the force and torque acting on a grain
 */
class ElectricBCMat :
    public DerivativeMaterialInterface<Material>
{
public:
  ElectricBCMat(const InputParameters & parameters);

  virtual void computeQpProperties();

protected:

  unsigned int _c_var;
  const VariableValue & _c;
  const VariableValue & _elec;
  const VariableGradient & _grad_c;

  const unsigned int _op_num;
  std::vector<const VariableValue *> _vals;

  Function & _left_func;
  Function & _right_func;
  Function & _top_func;
  Function & _bottom_func;
  MooseEnum _bc_type;

  MultiMooseEnum _boundary_side;
  unsigned int _boundary_num;

  MaterialProperty<Real> & _elec_bc;
  MaterialProperty<Real> & _delec_bc;
  MaterialProperty<Real> & _gb;
  MaterialProperty<RealGradient> & _c_norm;
  MaterialProperty<RealGradient> & _c_norm1;
};

#endif //ELECTRICBCMAT_H
