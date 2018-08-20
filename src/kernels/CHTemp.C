#include "CHTemp.h"

registerMooseObject("CrowApp", CHTemp);

template <> InputParameters validParams<CHTemp>() {
  InputParameters params = CHBulk<Real>::validParams();
  params.addRequiredParam<Real>("Temperature", "Process Temperature");
  params.addParam<Real>("R", 8.3144621e-3,
                        "Universal Gas Constant in kilo J K−1 mol−1");
  return params;
}

CHTemp::CHTemp(const InputParameters &parameters)
    : CHBulk<Real>(parameters), _temp(getParam<Real>("Temperature")),
      _r(getParam<Real>("R")) {}

RealGradient // Use This an example of the the function should look like
CHTemp::computeGradDFDCons(PFFunctionType type) {
  switch (type) {
  case Residual:
    return 12 * 16 * _u[_qp] * _u[_qp] * _grad_u[_qp] -
           12 * 16 * _u[_qp] * _grad_u[_qp] + 34 * _grad_u[_qp] +
           _r * _temp * _grad_u[_qp] * 2.0 +
           _r * _temp * _grad_u[_qp] / _u[_qp] +
           _r * _temp * _grad_u[_qp] / (1 - _u[_qp]); // return Residual value

  case Jacobian:
    return 24 * 16 * _u[_qp] * _phi[_j][_qp] * _grad_u[_qp] -
           12 * 16 * _phi[_j][_qp] * _grad_u[_qp] +
           12 * 16 * _u[_qp] * _u[_qp] * _grad_phi[_j][_qp] -
           12 * 16 * _u[_qp] * _grad_phi[_j][_qp] + 34 * _grad_phi[_j][_qp] +
           _r * _temp * _grad_phi[_j][_qp] / _u[_qp] +
           _r * _temp * _grad_phi[_j][_qp] / (1 - _u[_qp]) -
           _r * _temp * _phi[_j][_qp] * _grad_u[_qp] / (_u[_qp] * _u[_qp]) +
           _r * _temp * _phi[_j][_qp] * _grad_u[_qp] /
               ((1 - _u[_qp]) * (1 - _u[_qp])); // return Jacobian value
  }

  mooseError("Invalid type passed in");
}
