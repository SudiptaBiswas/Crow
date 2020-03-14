/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef ELECTRICBCUO_H
#define ELECTRICBCUO_H

#include "DerivativeMaterialInterface.h"
#include "ElementUserObject.h"
#include "Function.h"

// Forward Declarations
class ElectricBCUO;

template <> InputParameters validParams<ElectricBCUO>();

/**
 * This class is here to get the force and torque acting on a grain
 */
class ElectricBCUO : public DerivativeMaterialInterface<ElementUserObject> {
public:
  ElectricBCUO(const InputParameters &parameters);

  virtual void initialize();
  virtual void execute();
  virtual void finalize();
  virtual void threadJoin(const UserObject &y);

  virtual const Real &getBCValues() const;

protected:
  unsigned int _qp;

  unsigned int _c_var;
  const VariableValue &_c;
  const VariableGradient &_grad_c;

  const Function &_func;
  MooseEnum _bc_type;

  Real _value;
};

#endif // ELECTRICBCUO_H
