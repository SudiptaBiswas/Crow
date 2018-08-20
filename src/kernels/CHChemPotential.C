#include "CHChemPotential.h"

registerMooseObject("CrowApp", CHChemPotential);

template <> InputParameters validParams<CHChemPotential>() {
  InputParameters params = CHBulk<Real>::validParams();

  return params;
}

CHChemPotential::CHChemPotential(const InputParameters &parameters)
    : CHBulk<Real>(parameters) {}

RealGradient // Use This an example of the the function should look like
CHChemPotential::computeGradDFDCons(PFFunctionType type) {
  switch (type) {
  case Residual:
    return 12 * 16 * _u[_qp] * _u[_qp] * _grad_u[_qp] -
           12 * 16 * _u[_qp] * _grad_u[_qp] +
           34 * _grad_u[_qp]; // return Residual value

  case Jacobian:
    return 24 * 16 * _u[_qp] * _phi[_j][_qp] * _grad_u[_qp] -
           12 * 16 * _phi[_j][_qp] * _grad_u[_qp] +
           12 * 16 * _u[_qp] * _u[_qp] * _grad_phi[_j][_qp] -
           12 * 16 * _u[_qp] * _grad_phi[_j][_qp] +
           34 * _grad_phi[_j][_qp]; // return Jacobian value
  }

  mooseError("Invalid type passed in");
}
