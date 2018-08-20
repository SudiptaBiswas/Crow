#include "FEProblem.h"
#include "Factory.h"
#include "Parser.h"
#include "TwoParticleGrainsICAction.h"

#include <sstream>
#include <stdexcept>

// libMesh includes
#include "libmesh/equation_systems.h"
#include "libmesh/exodusII_io.h"
#include "libmesh/explicit_system.h"
#include "libmesh/libmesh.h"
#include "libmesh/nonlinear_implicit_system.h"
#include "libmesh/string_to_enum.h"

registerMooseAction("CrowApp", TwoParticleGrainsICAction, "add_ic");

const Real TwoParticleGrainsICAction::_abs_zero_tol = 1e-12;

template <> InputParameters validParams<TwoParticleGrainsICAction>() {
  InputParameters params = validParams<Action>();
  params.addRequiredParam<unsigned int>("op_num",
                                        "number of order parameters to create");
  params.addRequiredParam<std::string>(
      "var_name_base", "specifies the base name of the variables");

  return params;
}

TwoParticleGrainsICAction::TwoParticleGrainsICAction(
    const InputParameters &params)
    : Action(params), _var_name_base(getParam<std::string>("var_name_base")),
      _op_num(getParam<unsigned int>("op_num")) {}

void TwoParticleGrainsICAction::act() {
#ifdef DEBUG
  Moose::err << "Inside the TwoParticleGrainsICAction Object\n";
#endif

  // Loop through the number of order parameters
  for (unsigned int op = 0; op < _op_num; op++) {
    // Create variable names
    std::string var_name = _var_name_base;
    std::stringstream out;
    out << op;
    var_name.append(out.str());

    // Set parameters for BoundingBoxIC
    InputParameters poly_params =
        _factory.getValidParams("TwoParticleGrainsIC");
    poly_params.set<VariableName>("variable") = var_name;
    poly_params.set<unsigned int>("op_num") = _op_num;
    poly_params.set<unsigned int>("op_index") = op;

    // Add initial condition
    _problem->addInitialCondition("TwoParticleGrainsIC", "InitialCondition",
                                  poly_params);
  }
}
