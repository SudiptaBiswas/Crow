#include "PolycrystalSinteringKernelAction.h"
#include "Factory.h"
#include "Parser.h"
#include "FEProblem.h"

template<>
InputParameters validParams<PolycrystalSinteringKernelAction>()
{
  InputParameters params = validParams<Action>();
  //params += DerivativeKernelInterface<ACBulk>::validParams();
  params.addRequiredParam<unsigned int>("op_num", "specifies the number of grains to create");
  params.addRequiredParam<std::string>("var_name_base", "specifies the base name of the variables");
  params.addParam<VariableName>("c", "NONE", "Name of coupled concentration variable");
  params.addParam<Real>("en_ratio", 1.0, "Ratio of surface to GB energy");
  params.addParam<bool>("implicit", true, "Whether kernels are implicit or not");
  params.addParam<VariableName>("T", "NONE", "Name of temperature variable");
  params.addParam<std::vector<VariableName > >("v", "Array of coupled variable names");
  params.addParam<bool>("use_displaced_mesh", false, "Whether to use displaced mesh in the kernels");
  //InputParameters 
  //params.addParam<std::vector<VariableName > >("args", "Vector of additional arguments to F");

  return params;
}

PolycrystalSinteringKernelAction::PolycrystalSinteringKernelAction(InputParameters params) :
    Action(params),
    //DerivativeKernelInterface<JvarMapInterface<ACBulk> >(name, parameters),
    _op_num(getParam<unsigned int>("op_num")),
    _var_name_base(getParam<std::string>("var_name_base")),
    _c(getParam<VariableName>("c")),
    _implicit(getParam<bool>("implicit")),
    _T(getParam<VariableName>("T")),
    _vals(getParam<std::vector<VariableName > >("v"))
    //_args(getParam<std::vector<VariableName > >("args")
    
{
}

void
PolycrystalSinteringKernelAction::act()
{
#ifdef DEBUG
  Moose::err << "Inside the PolyCrystalSinteringKernelAction Object\n";
  Moose::err << "var name base:" << _var_name_base;
#endif
  // Moose::out << "Implicit = " << _implicit << Moose::out;

  for (unsigned int op = 0; op < _op_num; op++)
  {
    //Create variable names
    std::string var_name = _var_name_base;
    std::stringstream out;
    out << op;
    var_name.append(out.str());

    std::vector<VariableName> v;
    v.resize(_op_num - 1);

    unsigned int ind = 0;

    for (unsigned int j = 0; j < _op_num; j++)
    {
      if (j != op)
      {
        std::string coupled_var_name = _var_name_base;
        std::stringstream out2;
        out2 << j;
        coupled_var_name.append(out2.str());
        v[ind] = coupled_var_name;
        ind++;
      }
    }

    //InputParameters poly_params = _factory.getValidParams("ACSinteringGrowth");
    //poly_params.set<NonlinearVariableName>("variable") = var_name;
    //poly_params.set<std::vector<VariableName> >("v") = v;
    //poly_params.set<bool>("implicit")=_implicit;
    //poly_params.set<bool>("use_displaced_mesh") = getParam<bool>("use_displaced_mesh");
    //if (_T != "NONE")
     // poly_params.set<std::vector<VariableName> >("T").push_back(_T);

    //std::string kernel_name = "ACBulkSinter_";
    //kernel_name.append(var_name);

    //_problem->addKernel("ACSinteringGrowth", kernel_name, poly_params);
    
    /************/
    
    InputParameters poly_params = _factory.getValidParams("ACInterface");
    poly_params.set<NonlinearVariableName>("variable") = var_name;
    poly_params.set<bool>("implicit")=getParam<bool>("implicit");
    poly_params.set<bool>("use_displaced_mesh") = getParam<bool>("use_displaced_mesh");

    std::string kernel_name = "ACInt_";
    kernel_name.append(var_name);

    _problem->addKernel("ACInterface", kernel_name, poly_params);
    
    //*******************

    poly_params = _factory.getValidParams("TimeDerivative");
    poly_params.set<NonlinearVariableName>("variable") = var_name;
    poly_params.set<bool>("implicit") = true;
    poly_params.set<bool>("use_displaced_mesh") = getParam<bool>("use_displaced_mesh");

    kernel_name = "IE_";
    kernel_name.append(var_name);

    _problem->addKernel("TimeDerivative", kernel_name, poly_params);

    /************/
  if (_c != "NONE")
  {
    poly_params = _factory.getValidParams("ACParticleGrowth");
    poly_params.set<NonlinearVariableName>("variable") = var_name;
    poly_params.set<std::vector<VariableName> >("c").push_back(_c);
    poly_params.set<std::vector<VariableName> >("v") = _vals;
    poly_params.set<bool>("implicit")=getParam<bool>("implicit");
    poly_params.set<bool>("use_displaced_mesh") = getParam<bool>("use_displaced_mesh");

    kernel_name = "ACBulk_";
    kernel_name.append(var_name);

    _problem->addKernel("ACParticleGrowth", kernel_name, poly_params);
    //*******************
  } 
  
 // if (_disp == true)
  //{
   // poly_params = _factory.getValidParams("ACParsed");
   // poly_params.set<NonlinearVariableName>("variable") = var_name;
    //poly_params.set<c >("c").push_back(_c);
    //poly_params.set<std::vector<VariableName> >("args") = _args;
   // poly_params.set<bool>("implicit")=getParam<bool>("implicit");
    //poly_params.set<bool>("use_displaced_mesh") = getParam<bool>("use_displaced_mesh");

   // kernel_name = "ElstcEn_";
    //kernel_name.append(var_name);

    //_problem->addKernel("ACParsed", kernel_name, poly_params);
    //*******************
  //}    
  }
}
