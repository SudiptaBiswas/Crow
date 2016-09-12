#ifndef RigidBodyMotionKernel_H
#define RigidBodyMotionKernel_H

#include "KernelGrad.h"

//Forward Declarations
class RigidBodyMotionKernel;

template<>
InputParameters validParams<RigidBodyMotionKernel>();

/**
 * This kernel calculates the residual for grain growth during sintering.
 * It calculates the residual of the ith order parameter, and the values of
 * all other order parameters are coupled variables and are stored in vals.
 */
class RigidBodyMotionKernel : public KernelGrad
{
public:
  RigidBodyMotionKernel(const InputParameters & parameters);

protected:
  virtual RealGradient precomputeQpResidual();
  virtual RealGradient precomputeQpJacobian();
  
  std::string _k_name;

private:
  std::vector<const VariableValue *> _vals;
  std::vector<const VariableGradient *> _grad_vals;
  std::vector<unsigned int> _vals_var;
  std::vector<Real> _SumEtaj;
  std::vector<RealGradient> _GradEtaj;
  
  const MaterialProperty<Real> & _k;
  Real _ceq;
  Real _cgb;
  Real _mt;
 
  unsigned int _ncrys;
 
  

  //VariableValue & _c;
};

#endif //RigidBodyMotionKernel_h
