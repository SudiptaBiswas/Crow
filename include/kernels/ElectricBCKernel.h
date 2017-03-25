#ifndef ELECTRICBCKERNEL_H
#define ELECTRICBCKERNEL_H

#include "HeatSource.h"
#include "JvarMapInterface.h"
#include "DerivativeMaterialInterface.h"

//Forward Declarations
class ElectricBCKernel;

template<>
InputParameters validParams<ElectricBCKernel>();

/**
 * This kernel calculates the heat source term corresponding to joule heating,
 * Q = J * E = elec_cond * grad_phi * grad_phi, where phi is the electrical potenstial.
 */
class ElectricBCKernel : public DerivativeMaterialInterface<JvarMapKernelInterface<HeatSource> >
{
public:
  ElectricBCKernel(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();

private:
  const MaterialProperty<Real> & _elec_bc;
  const MaterialProperty<Real> & _delec_bc;
};

#endif //ELECTRICBCKERNEL_H
