#include "AppFactory.h"
#include "CrowApp.h"
#include "Moose.h"
#include "MooseSyntax.h"
// #include "ModulesApp.h"

#include "HeatConductionApp.h"
#include "MiscApp.h"
#include "PhaseFieldApp.h"
#include "TensorMechanicsApp.h"

#ifdef MARMOT_ENABLED
#include "MarmotApp.h"
#include "MarmotSyntax.h"
#endif

#include "CrowRevision.h"
// #include "CrowSyntax.h"

template <> InputParameters validParams<CrowApp>() {
  InputParameters params = validParams<MooseApp>();
  return params;
}

registerKnownLabel("CrowApp");

CrowApp::CrowApp(const InputParameters &parameters) : MooseApp(parameters) {

  Moose::registerObjects(_factory);
  CrowApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  CrowApp::associateSyntax(_syntax, _action_factory);

  Moose::registerExecFlags(_factory);
  CrowApp::registerExecFlags(_factory);

  //   PhaseFieldApp::registerObjects(_factory);
  //   TensorMechanicsApp::registerObjects(_factory);
  //   HeatConductionApp::registerObjects(_factory);
  //   MiscApp::registerObjects(_factory);
  //
  //   PhaseFieldApp::associateSyntax(_syntax, _action_factory);
  //   TensorMechanicsApp::associateSyntax(_syntax, _action_factory);
  //   HeatConductionApp::associateSyntax(_syntax, _action_factory);
  //   MiscApp::associateSyntax(_syntax, _action_factory);
  //
  // #ifdef MARMOT_ENABLED
  //   MarmotApp::registerObjects(_factory);
  //   Marmot::associateSyntax(_syntax, _action_factory);
  // #endif

  CrowApp::associateSyntax(_syntax, _action_factory);
}

CrowApp::~CrowApp() {}

extern "C" void CrowApp__registerApps() { CrowApp::registerApps(); }
void CrowApp::registerApps() { registerApp(CrowApp); }

extern "C" void CrowApp__registerObjects(Factory &factory) {
  CrowApp::registerObjects(factory);
}
void CrowApp::registerObjects(Factory &factory) {
  PhaseFieldApp::registerObjects(factory);
  TensorMechanicsApp::registerObjects(factory);
  HeatConductionApp::registerObjects(factory);
  MiscApp::registerObjects(factory);
#ifdef MARMOT_ENABLED
  MarmotApp::registerObjects(factory);
#endif
  Registry::registerObjectsTo(factory, {"CrowApp"});
}

extern "C" void CrowApp__associateSyntax(Syntax &syntax,
                                         ActionFactory &action_factory) {
  CrowApp::associateSyntax(syntax, action_factory);
}
void CrowApp::associateSyntax(Syntax &syntax, ActionFactory &action_factory) {
  PhaseFieldApp::associateSyntax(syntax, action_factory);
  TensorMechanicsApp::associateSyntax(syntax, action_factory);
  HeatConductionApp::associateSyntax(syntax, action_factory);
  MiscApp::associateSyntax(syntax, action_factory);
#ifdef MARMOT_ENABLED
  Marmot::associateSyntax(syntax, action_factory);
#endif
  Registry::registerActionsTo(action_factory, {"CrowApp"});

  registerSyntax("PolycrystalSinteringKernelAction",
                 "Kernels/PolycrystalSinteringKernel");
  registerSyntax("PolycrystalSinteringMaterialAction",
                 "Materials/PolycrystalSinteringMaterial");
  registerSyntax("TwoParticleGrainsICAction",
                 "ICs/PolycrystalICs/TwoParticleGrainsIC");
  registerSyntax("BicrystalICAction", "ICs/PolycrystalICs/BicrystalIC");
  registerSyntax("MultiSmoothParticleICAction",
                 "ICs/PolycrystalICs/MultiSmoothParticleIC");
}

// External entry point for dynamic execute flag registration
extern "C" void CrowApp__registerExecFlags(Factory &factory) {
  CrowApp::registerExecFlags(factory);
}

void CrowApp::registerExecFlags(Factory &factory) {
  HeatConductionApp::registerExecFlags(factory);
  MiscApp::registerExecFlags(factory);
  PhaseFieldApp::registerExecFlags(factory);
  TensorMechanicsApp::registerExecFlags(factory);
  // #ifdef MARMOT_ENABLED
  //   Marmot::registerExecFlags(factory);
  // #endif
}
