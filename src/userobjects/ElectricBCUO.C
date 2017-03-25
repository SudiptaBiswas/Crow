/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "ElectricBCUO.h"
#include "GrainTrackerInterface.h"

// libmesh includes
#include "libmesh/quadrature.h"

template<>
InputParameters validParams<ElectricBCUO>()
{
  InputParameters params = validParams<ElementUserObject>();
  params.addClassDescription("Userobject for calculating force and torque acting on a grain");
  params.addParam<MaterialPropertyName>("force_density", "force_density", "Force density material");
  params.addParam<UserObjectName>("grain_data", "center of mass of grains");
  params.addCoupledVar("c", "Concentration field");
  params.addCoupledVar("etas", "Array of coupled order parameters");
  params.addRequiredParam<FunctionName>("function", "The forcing function.");
  MooseEnum bc_type("Dirichlet=0 Neumann", "SIMPLE");
  params.addParam<MooseEnum>("bc_type", bc_type, "Type of boundary condition. ");
  params.set<std::string>("function_name") = std::string("h");

  return params;
}

ElectricBCUO::ElectricBCUO(const InputParameters & parameters) :
    DerivativeMaterialInterface<ElementUserObject>(parameters),
    // GrainForceAndTorqueInterface(),
    _c_var(coupled("c")),
    _c(coupledValue("c")),
    _grad_c(coupledGradient("c")),
    _func(getFunction("function")),
    _bc_type(getParam<MooseEnum>("bc_type"))
{
}

void
ElectricBCUO::initialize()
{
  _value = 0.0;
}

void
ElectricBCUO::execute()
{
  Real tol = 0.0001;
  for (_qp=0; _qp<_qrule->n_points(); ++_qp)
  {
    RealGradient ns(0);

    if (_grad_c[_qp].norm() > 1.0e-10)
      ns = _grad_c[_qp] / _grad_c[_qp].norm();

      switch (_bc_type)
      {
        case 0: // dirichlet
          if (ns(0) - 1.0 < tol || ns(1) - 1.0 < tol || ns(2) - 1.0 > tol)
            _value = _c[_qp] - _func.value(_t, _q_point[_qp]);

          break;

        case 1: // Neumann
          if (ns(0) - 1.0 < tol || ns(1) - 1.0 < tol || ns(2) - 1.0 > tol)
            _value = - _func.value(_t, _q_point[_qp]);

          break;

        default:
          mooseError("Incorrect BC type for electrical BC.");
      }
  }
}

void
ElectricBCUO::finalize()
{
  gatherSum(_value);
}

void
ElectricBCUO::threadJoin(const UserObject & y)
{
  const ElectricBCUO & pps = static_cast<const ElectricBCUO &>(y);
  _value += pps._value;
}

const Real &
ElectricBCUO::getBCValues() const
{
  return _value;
}
