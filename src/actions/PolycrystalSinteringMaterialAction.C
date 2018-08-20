#include "FEProblem.h"
#include "Factory.h"
#include "Parser.h"
#include "PolycrystalSinteringMaterialAction.h"

registerMooseAction("CrowApp", PolycrystalSinteringMaterialAction,
                    "add_material");

template <> InputParameters validParams<PolycrystalSinteringMaterialAction>() {
  InputParameters params = validParams<Action>();
  params += validParams<Material>();
  params.addRequiredParam<unsigned int>(
      "op_num", "specifies the number of grains to create");
  params.addRequiredParam<std::string>(
      "var_name_base", "specifies the base name of the variables");
  // params.addParam<VariableName>("c", "NONE", "Name of coupled concentration
  // variable");  params.addParam<Real>("en_ratio", 1.0, "Ratio of surface to GB
  // energy");
  params.addParam<bool>("implicit", true,
                        "Whether kernels are implicit or not");
  params.addParam<bool>("disp", false, "dispcement present or not");
  params.addParam<bool>("use_displaced_mesh", false,
                        "Whether to use displaced mesh in the kernels");

  return params;
}

PolycrystalSinteringMaterialAction::PolycrystalSinteringMaterialAction(
    const InputParameters &params)
    : Action(params),
      // Material(name, params),
      _op_num(getParam<unsigned int>("op_num")),
      _var_name_base(getParam<std::string>("var_name_base")),
      //_c(getParam<VariableName>("c")),
      _implicit(getParam<bool>("implicit")), _disp(getParam<bool>("disp")) {}

void PolycrystalSinteringMaterialAction::act() {
#ifdef DEBUG
  Moose::err << "Inside the PolycrystalSinteringMaterialAction Object\n";
  Moose::err << "var name base:" << _var_name_base;
#endif
  // Moose::out << "Implicit = " << _implicit << Moose::out;

  for (unsigned int op = 0; op < _op_num; op++) {
    // Create variable names
    std::string var_name = _var_name_base;
    std::stringstream out;
    out << op;
    var_name.append(out.str());

    std::vector<VariableName> v;
    v.resize(_op_num - 1);

    unsigned int ind = 0;

    for (unsigned int j = 0; j < _op_num; j++) {
      if (j != op) {
        std::string coupled_var_name = _var_name_base;
        std::stringstream out2;
        out2 << j;
        coupled_var_name.append(out2.str());
        v[ind] = coupled_var_name;
        ind++;
      }
    }

    InputParameters poly_params = _factory.getValidParams("PFDiffusionGrowth");
    poly_params.set<NonlinearVariableName>("variable") = var_name;
    poly_params.set<std::vector<VariableName>>("v") = v;
    poly_params.set<bool>("implicit") = _implicit;
    poly_params.set<bool>("use_displaced_mesh") =
        getParam<bool>("use_displaced_mesh");
    // if (_T != "NONE")
    // poly_params.set<std::vector<VariableName> >("T").push_back(_T);

    std::string material_name = "PFDiffusionGrowth_";
    material_name.append(var_name);

    _problem->addMaterial("PFDiffusionGrowth", material_name, poly_params);

    /************/
    if (_disp == true) {
      poly_params = _factory.getValidParams("PFEigenStrainMaterial1");
    }
    poly_params.set<NonlinearVariableName>("variable") = var_name;
    poly_params.set<std::vector<VariableName>>("v") = v;
    poly_params.set<bool>("implicit") = _implicit;
    poly_params.set<bool>("use_displaced_mesh") =
        getParam<bool>("use_displaced_mesh");
    // if (_T != "NONE")
    // poly_params.set<std::vector<VariableName> >("T").push_back(_T);

    material_name = "PFEigenStrainMaterial1_";
    material_name.append(var_name);

    _problem->addMaterial("PFEigenStrainMaterial1", material_name, poly_params);
  }
}
