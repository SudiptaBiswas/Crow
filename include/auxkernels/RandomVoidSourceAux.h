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

#ifndef RANDOMAUX_H
#define RANDOMAUX_H

#include "AuxKernel.h"
#include "ConservedNoiseBase.h"

// Forward Declarations
class RandomVoidSourceAux;
class RandomElementalUserObject;

template <> InputParameters validParams<RandomVoidSourceAux>();

/**
 * An AuxKernel that uses built-in Random number generation.
 */
class RandomVoidSourceAux : public AuxKernel {
public:
  RandomVoidSourceAux(const InputParameters &params);

  virtual ~RandomVoidSourceAux();

protected:
  virtual Real computeValue();

  const ConservedNoiseInterface *_random_uo;
  bool _generate_ints;
};

#endif // RANDOMAUX_H
