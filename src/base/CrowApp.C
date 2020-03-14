#include "AppFactory.h"
#include "CrowApp.h"
#include "Moose.h"
#include "MooseSyntax.h"

#include "HeatConductionApp.h"
#include "MiscApp.h"
#include "PhaseFieldApp.h"
#include "TensorMechanicsApp.h"

#ifdef MARMOT_ENABLED
#include "MarmotApp.h"
#endif

#include "CrowRevision.h"

template <> InputParameters validParams<CrowApp>() {
  InputParameters params = validParams<MooseApp>();
  return params;
}

registerKnownLabel("CrowApp");

CrowApp::CrowApp(const InputParameters &parameters) : MooseApp(parameters) {
  CrowApp::registerAll(_factory, _action_factory, _syntax);
}

CrowApp::~CrowApp() {}

void CrowApp::associateSyntax(Syntax &syntax,
                              ActionFactory & /*action_factory*/) {
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

// External entry point for dynamic application loading
extern "C" void CrowApp__registerApps() { CrowApp::registerApps(); }
void CrowApp::registerApps() { registerApp(CrowApp); }

// External entry point for object registration
extern "C" void CrowApp__registerAll(Factory &factory,
                                     ActionFactory &action_factory,
                                     Syntax &syntax) {
  CrowApp::registerAll(factory, action_factory, syntax);
}
void CrowApp::registerAll(Factory &factory, ActionFactory &action_factory,
                          Syntax &syntax) {
  Registry::registerObjectsTo(factory, {"CrowApp"});
  Registry::registerActionsTo(action_factory, {"CrowApp"});
  CrowApp::associateSyntax(syntax, action_factory);

  PhaseFieldApp::registerAll(factory, action_factory, syntax);
  TensorMechanicsApp::registerAll(factory, action_factory, syntax);
  HeatConductionApp::registerAll(factory, action_factory, syntax);
  MiscApp::registerAll(factory, action_factory, syntax);

#ifdef MARMOT_ENABLED
  MarmotApp::registerAll(factory, action_factory, syntax);
#endif
}
