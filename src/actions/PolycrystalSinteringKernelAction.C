#include "Conversion.h"
#include "FEProblem.h"
#include "Factory.h"
#include "Parser.h"
#include "PolycrystalSinteringKernelAction.h"

registerMooseAction("CrowApp", PolycrystalSinteringKernelAction, "add_kernel");

template <> InputParameters validParams<PolycrystalSinteringKernelAction>() {
  InputParameters params = validParams<Action>();
  params.addRequiredParam<unsigned int>(
      "op_num", "specifies the number of grains to create");
  params.addRequiredParam<std::string>(
      "var_name_base", "specifies the base name of the variables");
  params.addParam<VariableName>("c", "NONE",
                                "Name of coupled concentration variable");
  params.addParam<MaterialPropertyName>("mob_name", "L",
                                        "The mobility used with the kernel");
  params.addParam<MaterialPropertyName>("kappa_name", "kappa_op",
                                        "The kappa used with the kernel");
  params.addParam<std::string>("base_name", "Optional parameter that allows "
                                            "the user to define type of force "
                                            "density under consideration");
  params.addParam<Real>("translation_constant", 500,
                        "constant value characterizing grain translation");
  params.addParam<Real>("rotation_constant", 1.0,
                        "constant value characterizing grain rotation");
  params.addParam<Real>(
      "int_width", "The interfacial width in the lengthscale of the problem");
  params.addParam<Real>("length_scale", 1.0e-9,
                        "Length scale in m, where default is 1 nm");
  params.addParam<UserObjectName>(
      "grain_force", "grain_force",
      "userobject for getting force and torque acting on grains");
  params.addParam<UserObjectName>(
      "grain_tracker_object", "grain_center",
      "The FeatureFloodCount UserObject to get values from.");
  params.addParam<UserObjectName>("gbenergymap",
                                  "Where the map of the energies are held");
  params.addParam<VectorPostprocessorName>(
      "grain_volumes", "grain_volumes",
      "The feature volume VectorPostprocessorValue.");
  params.addParam<bool>(
      "consider_rigidbodymotion", true,
      "Whether to consider riogidbodymotion or particles or not");
  params.addParam<bool>(
      "anisotropic", true,
      "Whether to consider riogidbodymotion or particles or not");
  params.addParam<bool>("implicit", true,
                        "Whether kernels are implicit or not");
  params.addParam<bool>("use_displaced_mesh", false,
                        "Whether to use displaced mesh in the kernels");

  return params;
}

PolycrystalSinteringKernelAction::PolycrystalSinteringKernelAction(
    const InputParameters &params)
    : Action(params), _op_num(getParam<unsigned int>("op_num")),
      _var_name_base(getParam<std::string>("var_name_base")),
      _c(getParam<VariableName>("c")),
      _mob_name(getParam<MaterialPropertyName>("mob_name")),
      _kappa_name(getParam<MaterialPropertyName>("kappa_name")),
      _consider_rbm(getParam<bool>("consider_rigidbodymotion")),
      _anisotropic(getParam<bool>(("anisotropic"))),
      _implicit(getParam<bool>("implicit")) {}

void PolycrystalSinteringKernelAction::act() {
#ifdef DEBUG
  Moose::err << "Inside the PolyCrystalSinteringKernelAction Object\n";
  Moose::err << "var name base:" << _var_name_base;
#endif

  for (unsigned int op = 0; op < _op_num; ++op) {
    // Create variable names

    std::string var_name = _var_name_base + Moose::stringify(op);
    std::vector<VariableName> v;
    v.resize(_op_num - 1);

    unsigned int ind = 0;
    for (unsigned int j = 0; j < _op_num; ++j)
      if (j != op)
        v[ind++] = _var_name_base + Moose::stringify(j);

    InputParameters poly_params = _factory.getValidParams("ACParticleGrowth");
    poly_params.set<NonlinearVariableName>("variable") = var_name;
    poly_params.set<std::vector<VariableName>>("c").push_back(_c);
    poly_params.set<std::vector<VariableName>>("v") = v;
    poly_params.set<MaterialPropertyName>("mob_name") = _mob_name;
    poly_params.set<bool>("implicit") = _implicit;
    poly_params.set<bool>("use_displaced_mesh") =
        getParam<bool>("use_displaced_mesh");

    std::string kernel_name = "ACBulk_";
    kernel_name.append(var_name);

    _problem->addKernel("ACParticleGrowth", kernel_name, poly_params);

    //********************************************

    poly_params = _factory.getValidParams("ACInterface");
    poly_params.set<NonlinearVariableName>("variable") = var_name;
    poly_params.set<MaterialPropertyName>("mob_name") = _mob_name;
    poly_params.set<MaterialPropertyName>("kappa_name") = _kappa_name;
    poly_params.set<bool>("implicit") = _implicit;
    poly_params.set<bool>("use_displaced_mesh") =
        getParam<bool>("use_displaced_mesh");

    kernel_name = "ACInt_";
    kernel_name.append(var_name);

    _problem->addKernel("ACInterface", kernel_name, poly_params);

    //*****************************************

    poly_params = _factory.getValidParams("TimeDerivative");
    poly_params.set<NonlinearVariableName>("variable") = var_name;
    poly_params.set<bool>("implicit") = _implicit;
    poly_params.set<bool>("use_displaced_mesh") =
        getParam<bool>("use_displaced_mesh");

    kernel_name = "IE_";
    kernel_name.append(var_name);

    _problem->addKernel("TimeDerivative", kernel_name, poly_params);

    //
    // Set up SingleGrainRigidBodyMotion kernels
    //
    if (_consider_rbm) {
      std::vector<VariableName> etas(_op_num);
      for (unsigned int j = 0; j < _op_num; ++j)
        etas[j] = _var_name_base + Moose::stringify(j);

      InputParameters params =
          _factory.getValidParams("SingleGrainRigidBodyMotion");
      params.set<NonlinearVariableName>("variable") = var_name;
      params.set<std::vector<VariableName>>("v") = etas;
      params.set<unsigned int>("op_index") = op;
      params.set<std::vector<VariableName>>("c") = {
          getParam<VariableName>("c")};
      if (isParamValid("base_name"))
        params.set<std::string>("base_name") =
            getParam<std::string>("base_name");
      params.set<Real>("translation_constant") =
          getParam<Real>("translation_constant");
      params.set<Real>("rotation_constant") =
          getParam<Real>("rotation_constant");
      params.set<UserObjectName>("grain_force") =
          getParam<UserObjectName>("grain_force");
      params.set<UserObjectName>("grain_tracker_object") =
          getParam<UserObjectName>("grain_tracker_object");
      params.set<VectorPostprocessorName>("grain_volumes") =
          getParam<VectorPostprocessorName>("grain_volumes");

      params.set<bool>("implicit") = _implicit;
      params.set<bool>("use_displaced_mesh") =
          getParam<bool>("use_displaced_mesh");

      std::string kernel_name = "RigidBody_" + var_name;
      _problem->addKernel("SingleGrainRigidBodyMotion", kernel_name, params);
    }

    if (_anisotropic) {
      std::vector<VariableName> etas(_op_num);
      for (unsigned int j = 0; j < _op_num; ++j)
        etas[j] = _var_name_base + Moose::stringify(j);

      // std::vector<VariableName> v;
      // v.resize(_op_num - 1);
      //
      // unsigned int ind = 0;
      // for (unsigned int j = 0; j < _op_num; ++j)
      //   if (j != op)
      //   v[ind++] = _var_name_base + Moose::stringify(j);

      InputParameters poly_params =
          _factory.getValidParams("ACParticleGrowthAniso");
      poly_params.set<NonlinearVariableName>("variable") = var_name;
      poly_params.set<std::vector<VariableName>>("c").push_back(_c);
      poly_params.set<std::vector<VariableName>>("v") = etas;
      poly_params.set<MaterialPropertyName>("mob_name") = _mob_name;
      poly_params.set<unsigned int>("op") = op;
      poly_params.set<Real>("length_scale") = getParam<Real>("length_scale");
      poly_params.set<Real>("int_width") = getParam<Real>("int_width");
      poly_params.set<UserObjectName>("gbenergymap") =
          getParam<UserObjectName>("gbenergymap");
      poly_params.set<bool>("implicit") = _implicit;
      poly_params.set<bool>("use_displaced_mesh") =
          getParam<bool>("use_displaced_mesh");

      std::string kernel_name = "ACBulkAniso_";
      kernel_name.append(var_name);

      _problem->addKernel("ACParticleGrowthAniso", kernel_name, poly_params);
    }
  }
}
