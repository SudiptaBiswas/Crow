/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#ifndef NECKAREAPOSTPROCESSOR_H
#define NECKAREAPOSTPROCESSOR_H

#include "ElementIntegralVariablePostprocessor.h"

//Forward Declarations
class NeckAreaPostprocessor;

template<>
InputParameters validParams<NeckAreaPostprocessor>();

/**
 * This postprocessor computes a volume integral of the specified variable.
 *
 * Note that specializations of this integral are possible by deriving from this
 * class and overriding computeQpIntegral().
 */
class NeckAreaPostprocessor :
  public ElementIntegralPostprocessor
{
public:
  NeckAreaPostprocessor(const InputParameters & parameters);

protected:
  virtual Real computeQpIntegral() override;

  const unsigned int _op_num;
  std::vector<const VariableValue *> _vals;
};

#endif //NECKAREAPOSTPROCESSOR_H
