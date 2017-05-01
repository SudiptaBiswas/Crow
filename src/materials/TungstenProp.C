/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "TungstenProp.h"

// libmesh includes
#include "libmesh/quadrature.h"

template<>
InputParameters validParams<TungstenProp>()
{
  InputParameters params = validParams<Material>();
  params.addClassDescription("Userobject for calculating force and torque acting on a grain");
  params.addCoupledVar("T", "Temperature variable in K.");
  params.addParam<Real>("length_scale", 1e-9, "Length scale w.r.t m for unit conversion.");
  params.addParam<Real>("mass_scale", 1e-6, "Mass scale for unit conversion.");
  params.addParam<Real>("time_scale", 1e-6, "Time scale for simulation.");
  return params;
}

TungstenProp::TungstenProp(const InputParameters & parameters) :
    DerivativeMaterialInterface<Material>(parameters),
    _T(coupledValue("T")),
    _length_scale(getParam<Real>("length_scale")),
    _mass_scale(getParam<Real>("mass_scale")),
    _time_scale(getParam<Real>("time_scale")),
    _thermal_conductivity(declareProperty<Real>("thermal_conductivity")),
    _specific_heat(declareProperty<Real>("specific_heat")),
    _density(declareProperty<Real>("density"))
{
}

void
TungstenProp::computeQpProperties()
{
  _density[_qp] = 19.3 * 100e3 * _mass_scale / (_length_scale * _length_scale * _length_scale); // original unit g/cm^3 converted to simulations scale
  _thermal_conductivity[_qp] = 240.51 - 0.2899 * _T[_qp] + 2.5403e-4 * _T[_qp] * _T[_qp]
                               - 1.0263e-7 * _T[_qp] * _T[_qp] * _T[_qp]
                               + 1.5238e-11 * _T[_qp] * _T[_qp] * _T[_qp] * _T[_qp];

  _specific_heat[_qp] = 1.0;
}
