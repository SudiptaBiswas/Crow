/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "FEProblem.h"
#include "Factory.h"
#include "MultiSmoothParticleICAction.h"
#include "Parser.h"

#include <sstream>
#include <stdexcept>

// libMesh includes
#include "libmesh/equation_systems.h"
#include "libmesh/exodusII_io.h"
#include "libmesh/explicit_system.h"
#include "libmesh/libmesh.h"
#include "libmesh/nonlinear_implicit_system.h"
#include "libmesh/string_to_enum.h"

registerMooseAction("CrowApp", MultiSmoothParticleICAction, "add_ic");

const Real MultiSmoothParticleICAction::_abs_zero_tol = 1e-12;

template <> InputParameters validParams<MultiSmoothParticleICAction>() {
  InputParameters params = validParams<Action>();

  params.addRequiredParam<std::string>(
      "var_name_base", "specifies the base name of the variables");
  params.addRequiredParam<unsigned int>("op_num", "Number of order parameters");
  params.addRequiredParam<std::vector<Real>>(
      "x_positions", "The x-coordinate for each circle center");
  params.addRequiredParam<std::vector<Real>>(
      "y_positions", "The y-coordinate for each circle center");
  params.addRequiredParam<std::vector<Real>>(
      "z_positions", "The z-coordinate for each circle center");
  params.addRequiredParam<std::vector<Real>>("radii",
                                             "The radius for each circle");
  params.addParam<Real>("int_width", 0.0,
                        "The interfacial width of the void surface.  Defaults "
                        "to sharp interface");
  params.addParam<bool>("3D_spheres", true,
                        "in 3D, whether the objects are spheres or columns");
  return params;
}

MultiSmoothParticleICAction::MultiSmoothParticleICAction(
    const InputParameters params)
    : Action(params), _var_name_base(getParam<std::string>("var_name_base")),
      _op_num(getParam<unsigned int>("op_num")),
      _x_positions(getParam<std::vector<Real>>("x_positions")),
      _y_positions(getParam<std::vector<Real>>("y_positions")),
      _z_positions(getParam<std::vector<Real>>("z_positions")),
      _input_radii(getParam<std::vector<Real>>("radii")),
      _int_width(getParam<Real>("int_width")),
      _3D_spheres(getParam<bool>("3D_spheres")), _num_dim(_3D_spheres ? 3 : 2) {
}

void MultiSmoothParticleICAction::act() {
#ifdef DEBUG
  Moose::err << "Inside the MultiSmoothParticleICAction Object\n";
#endif

  // Loop through the number of order parameters
  for (unsigned int op = 0; op < _op_num; op++) {
    // Create variable names
    std::string var_name = _var_name_base;
    std::stringstream out;
    out << op;
    var_name.append(out.str());

    // Set parameters for SmoothCircleIC
    InputParameters poly_params = _factory.getValidParams("SmoothCircleIC");
    poly_params.set<VariableName>("variable") = var_name;
    poly_params.set<Real>("x1") = _x_positions[op];
    poly_params.set<Real>("y1") = _y_positions[op];
    if (_num_dim == 3) {
      poly_params.set<Real>("z1") = _z_positions[op];
    }

    poly_params.set<Real>("radius") = _input_radii[op];
    poly_params.set<unsigned int>("op_index") = op;
    poly_params.set<Real>("int_width") = _int_width;
    poly_params.set<bool>("3D_spheres") = _3D_spheres;
    // Values for circle grain
    poly_params.set<Real>("invalue") = 1.0;
    poly_params.set<Real>("outvalue") = 0.0;

    // Add initial condition
    _problem->addInitialCondition("SmoothCircleIC", "InitialCondition",
                                  poly_params);
  }
}
