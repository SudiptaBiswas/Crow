/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "ElectricBCMat.h"

// libmesh includes
#include "libmesh/quadrature.h"

template<>
InputParameters validParams<ElectricBCMat>()
{
  InputParameters params = validParams<Material>();
  params.addClassDescription("Userobject for calculating force and torque acting on a grain");
  params.addCoupledVar("c", "Concentration field");
  params.addCoupledVar("elec", "electric field");
  params.addRequiredCoupledVarWithAutoBuild("v", "var_name_base", "op_num", "Array of coupled variables");
  // params.addParam<Real>("tolerance", )
  params.addParam<FunctionName>("left_function", 0, "The forcing function.");
  params.addParam<FunctionName>("right_function", 0, "The forcing function.");
  params.addParam<FunctionName>("top_function", 0, "The forcing function.");
  params.addParam<FunctionName>("bottom_function", 0, "The forcing function.");
  MooseEnum bc_type("Dirichlet=0 Neumann", "Dirichlet");
  params.addParam<MooseEnum>("bc_type", bc_type, "Type of boundary condition. ");
  MultiMooseEnum boundary_side("Left Right Top Bottom Front Back", "Top");
  params.addRequiredParam<MultiMooseEnum>("boundary_side", boundary_side, "Specifying boundary side to apply the boundary condition as the materials property.");
  return params;
}

ElectricBCMat::ElectricBCMat(const InputParameters & parameters) :
    DerivativeMaterialInterface<Material>(parameters),
    _c_var(coupled("c")),
    _c(coupledValue("c")),
    _elec(coupledValue("elec")),
    _grad_c(coupledGradient("c")),
    _op_num(coupledComponents("v")),
    _vals(_op_num),
    _left_func(getFunction("left_function")),
    _right_func(getFunction("right_function")),
    _top_func(getFunction("top_function")),
    _bottom_func(getFunction("bottom_function")),
    _bc_type(getParam<MooseEnum>("bc_type")),
    _boundary_side(getParam<MultiMooseEnum>("boundary_side")),
    _boundary_num(_boundary_side.size()),
    _elec_bc(declareProperty<Real>("elecbc_mat")),
    _delec_bc(declareProperty<Real>("delecbc_mat")),
    _gb(declareProperty<Real>("gb")),
    _c_norm(declareProperty<RealGradient>("c_norm")),
    _c_norm1(declareProperty<RealGradient>("c_norm1"))
{
  for (unsigned int i = 0; i < _op_num; ++i)
    _vals[i] = &coupledValue("v", i);
}

void
ElectricBCMat::computeQpProperties()
{
  Real tol = 0.005;
  RealGradient ns(0);
  RealGradient check(0);

  if (_grad_c[_qp].norm() > tol)
    ns = _grad_c[_qp] / _grad_c[_qp].norm();

  Real gb = 0.0;
  for (unsigned int i = 0; i < _op_num; ++i)
    for (unsigned int j = 0; j < _op_num; ++j)
      if (i != j)
        gb = (*_vals[i])[_qp] * (*_vals[j])[_qp];

  _gb[_qp] = gb;

  _c_norm1[_qp] = ns;

  _elec_bc[_qp] = 0.0;
  _delec_bc[_qp] = 0.0;
  for (unsigned int i = 0; i < 3; ++i)
  {
    if (ns(i) >= 0.0)
      check(i) = 1.0 - ns(i);
    else
      check(i) = 1.0 + ns(i);
  }
  _c_norm[_qp] = check;

  switch (_bc_type)
  {
    case 0:

      for (unsigned int num = 0; num < _boundary_num; ++num)
      {
        if (_boundary_side[num] == "Top")
          if (ns(1) > 0.0 && check(1) < tol && gb == 0.0)
          {
            _elec_bc[_qp] = _elec[_qp] - _top_func.value(_t, _q_point[_qp]);
            _delec_bc[_qp] = 1.0;
          }
        if (_boundary_side[num] == "Bottom")
          if (ns(1) < 0.0 && check(1) < tol && gb == 0.0)
          {
            _elec_bc[_qp] = _elec[_qp] - _bottom_func.value(_t, _q_point[_qp]);
            _delec_bc[_qp] = 1.0;
          }
        if (_boundary_side[num] == "Left")
          if (ns(0) > 0.0 && check(0) < tol && gb == 0.0)
          {
            _elec_bc[_qp] = _elec[_qp] - _left_func.value(_t, _q_point[_qp]);
            _delec_bc[_qp] = 1.0;
          }
        if (_boundary_side[num] == "Right")
          if (ns(0) < 0.0 && check(0) < tol && gb == 0.0)
          {
            _elec_bc[_qp] = _elec[_qp] - _right_func.value(_t, _q_point[_qp]);
            _delec_bc[_qp] = 1.0;
          }
        //if (_boundary_side[num] == "Front")
          //if (ns(2) > 0.0 && check(0) < tol)
          //{
            //_elec_bc[_qp] = _elec[_qp] - _right_func.value(_t, _q_point[_qp]);
            //_delec_bc[_qp] = 1.0;
          //}
        //if (_boundary_side[num] == "Back")
          //if (ns(2) < 0.0 && check(0) < tol)
          //{
          //  _elec_bc[_qp] = _elec[_qp] - _right_func.value(_t, _q_point[_qp]);
            //_delec_bc[_qp] = 1.0;
          //}
    }
  //std::cout << "##qp = " << _qp << ", delecbc = " << _delec_bc[_qp] << ", ns1 = " << fabs(ns(1)) << std::endl;

    break;

    case 1: // Neumann
    for (unsigned int num = 0; num < _boundary_num; ++num)
    {
      if (_boundary_side[num] == "Top")
        if (ns(1) > 0.0 && check(1) < tol && gb == 0.0)
          _elec_bc[_qp] = - _top_func.value(_t, _q_point[_qp]);

      if (_boundary_side[num] == "Bottom")
        if (ns(1) < 0.0 && check(1) < tol && gb == 0.0)
          _elec_bc[_qp] = -_bottom_func.value(_t, _q_point[_qp]);

      if (_boundary_side[num] == "Left")
        if (ns(0) > 0.0 && check(0) < tol && gb == 0.0)
          _elec_bc[_qp] = -_left_func.value(_t, _q_point[_qp]);

      if (_boundary_side[num] == "Right")
        if (ns(0) < 0.0 && check(0) < tol && gb == 0.0)
          _elec_bc[_qp] = -_right_func.value(_t, _q_point[_qp]);
      }
        //_elec_bc[_qp] = - _func.value(_t, _q_point[_qp]);
      break;

    default:
     mooseError("Incorrect BC type for electric BC material.");
  }
}
