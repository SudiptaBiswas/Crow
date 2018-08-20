#include "ElectricBCKernel.h"

registerMooseObject("CrowApp", ElectricBCKernel);

template <> InputParameters validParams<ElectricBCKernel>() {
  InputParameters params = validParams<HeatSource>();
  params.addCoupledVar("elec", "Electric potential for joule heating.");
  params.addCoupledVar("args", "Vector of arguments of the diffusivity");
  params.addParam<MaterialPropertyName>(
      "electrical_conductivity", "electrical_conductivity",
      "material property providing electrical resistivity of the material.");
  return params;
}

ElectricBCKernel::ElectricBCKernel(const InputParameters &parameters)
    : DerivativeMaterialInterface<JvarMapKernelInterface<HeatSource>>(
          parameters),
      _elec_bc(getMaterialProperty<Real>("elecbc_mat")),
      _delec_bc(getMaterialProperty<Real>("delecbc_mat")) {}

Real ElectricBCKernel::computeQpResidual() {
  return -_elec_bc[_qp] * _test[_i][_qp];
}

Real ElectricBCKernel::computeQpJacobian() {
  return -_delec_bc[_qp] * _phi[_j][_qp] * _test[_i][_qp];
}
