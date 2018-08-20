#include "RigidBodyMotionKernel.h"

registerMooseObject("CrowApp", RigidBodyMotionKernel);

template <> InputParameters validParams<RigidBodyMotionKernel>() {
  InputParameters params = validParams<KernelGrad>();
  params.addRequiredCoupledVar("v", "Array of coupled order parameters");
  // params.addCoupledVar("c", "Concentration/density field");
  params.addParam<Real>("ceq", 0.9816, "Equilibrium density");
  params.addParam<Real>("cgb", 0.5, "Thresold Concentration for GB");
  params.addParam<Real>("mt", 500, "Particle translation constant");
  params.addParam<std::string>("k", "k", "stiffness constant");
  return params;
}

RigidBodyMotionKernel::RigidBodyMotionKernel(const InputParameters &parameters)
    : KernelGrad(parameters), _k_name(getParam<std::string>("k")),
      _k(getMaterialProperty<Real>(_k_name)), _ceq(getParam<Real>("ceq")),
      _cgb(getParam<Real>("cgb")), _mt(getParam<Real>("mt"))
//_c(coupledValue("c"))

{
  // Array of coupled variables is created in the constructor
  _ncrys = coupledComponents("v"); // determine number of grains from the number
                                   // of names passed in.  Note this is the
                                   // actual number -1
  _vals.resize(_ncrys);            // Size variable arrays
  _grad_vals.resize(_ncrys);
  _vals_var.resize(_ncrys);
  _SumEtaj.resize(_ncrys);
  _GradEtaj.resize(_ncrys);
  //_vadv.resize(_ncrys);
  // _gamma = 1.5;

  // Loop through grains and load coupled variables into the arrays
  for (unsigned int i = 0; i < _ncrys; ++i) {
    _vals[i] = &coupledValue("v", i);
    _grad_vals[i] = &coupledGradient("v", i);
    _vals_var[i] = coupled("v", i);
  }
}

RealGradient RigidBodyMotionKernel::precomputeQpResidual() {
  RealGradient vadv = 0.0;
  // RealGradient gard_vadv = 0.0;
  for (unsigned int i = 0; i < _ncrys; ++i) {
    _SumEtaj[i] = 0.0;
    _GradEtaj[i] = 0.0;

    for (unsigned int j = 0; j < _ncrys; ++j)
      if (j != i) {
        _SumEtaj[i] += (*_vals[i])[_qp] *
                       (*_vals[j])[_qp]; // Sum all other order parameters
        _GradEtaj[i] += ((*_grad_vals[i])[_qp] - (*_grad_vals[j])[_qp]);
      }
    Real SumEtajGB = 0.0;
    if (_SumEtaj[i] >= _cgb) {
      SumEtajGB = 1.0;
    }

    vadv += _mt * _k[_qp] * SumEtajGB * _GradEtaj[i];
    // grad_vadv + = _mt * _k[_qp]* SumEtajGB*_grad_u[_qp] *_GradEtaj[i] + ;
  }

  return _u[_qp] * _u[_qp] * vadv - _ceq * _u[_qp] * vadv;
}

RealGradient RigidBodyMotionKernel::precomputeQpJacobian() {
  RealGradient vadv = 0.0;

  // RealGradient gard_vadv = 0.0;
  for (unsigned int i = 0; i < _ncrys; ++i) {
    _SumEtaj[i] = 0.0;
    _GradEtaj[i] = 0.0;

    for (unsigned int j = 0; j < _ncrys; ++j)
      if (j != i) {
        _SumEtaj[i] += (*_vals[i])[_qp] *
                       (*_vals[j])[_qp]; // Sum all other order parameters
        _GradEtaj[i] += ((*_grad_vals[i])[_qp] - (*_grad_vals[j])[_qp]);
      }
    Real SumEtajGB = 0.0;
    if (_SumEtaj[i] >= _cgb) {
      SumEtajGB = 1.0;
    }

    vadv += _mt * _k[_qp] * SumEtajGB * _GradEtaj[i];
    // grad_vadv + = _mt* _k[_qp]* SumEtajGB*_grad_u[_qp] *_GradEtaj[i] + ;
  }

  return 2 * _u[_qp] * _phi[_j][_qp] * vadv - _ceq * _phi[_j][_qp] * vadv;
}
