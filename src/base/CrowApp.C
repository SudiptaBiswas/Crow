#include "CrowApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

#include "PhaseFieldApp.h"
#include "TensorMechanicsApp.h"
#include "HeatConductionApp.h"
#include "MiscApp.h"

// #include "MarmotApp.h"
// #include "MarmotSyntax.h"

#ifdef MARMOT_ENABLED
#  include "MarmotApp.h"
#  include "MarmotSyntax.h"
#endif

#include "CrowRevision.h"

#include "CHChemPotential.h"
#include "CHTemp.h"
#include "ACSinteringGrowth.h"
#include "ACParticleGrowth.h"
#include "ACParticleGrowthAniso.h"
#include "ElectricFieldKernel.h"
#include "ElectricBCKernel.h"
#include "VacancySourceTermKernel.h"
#include "RandomVacancySourceTermKernel.h"
#include "LangevinNoiseVoid.h"
#include "PFDiffusion.h"
#include "TempDiffusion.h"
#include "PFDiffusionGrowthConst.h"
#include "PFDiffusionGrowth.h"
#include "PFDiffusionGrowthMtrx.h"
#include "PFDiffusionGrowth1.h"
#include "PFParticleGrowth.h"
#include "PFEigenStrainMaterial.h"
#include "PFEigenStrainMaterial1.h"
#include "TwoParticleGrainsIC.h"
#include "PFTempMobility.h"
#include "Mobility.h"
#include "RandomVacancySourceTermMaterial.h"
#include "RandomNumberGeneration.h"
#include "ConservedLangevinNoiseVoidSource.h"
#include "BicrystalIC.h"
#include "RigidBodyMotionKernel.h"
#include "ResistivityMaterial.h"
#include "SinteringFreeEnergy.h"
#include "SinteringMobility.h"
#include "SinteringMtrxMobility.h"
#include "SinteringDiffusion.h"
#include "SinteringCoefficients.h"
#include "SinteringCoefficientsAniso.h"
#include "ThermalVariation.h"
#include "ElectricBCMat.h"
//#include "RadiationDefectSource.h"
//#include "RadiationDefectCreation.h"

#include "PolycrystalSinteringKernelAction.h"
#include "PolycrystalSinteringMaterialAction.h"
#include "TwoParticleGrainsICAction.h"
#include "TwoParticleDensityIC.h"
#include "BicrystalICAction.h"
#include "MultiSmoothParticleIC.h"
#include "MultiSmoothParticleICAction.h"

#include "RandomVoidSourceAux.h"

#include "ConservedUniformVoidSource.h"

#include "InterfaceAreaPostprocessor.h"
#include "NeckAreaPostprocessor.h"
// #include "ConservationCheck.h"

//#include "MobilityFn.h"

template<>
InputParameters validParams<CrowApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

CrowApp::CrowApp(const InputParameters & parameters) : MooseApp(parameters)
{
  Moose::registerObjects(_factory);

  PhaseFieldApp::registerObjects(_factory);
  TensorMechanicsApp::registerObjects(_factory);
  HeatConductionApp::registerObjects(_factory);
  MiscApp::registerObjects(_factory);

  CrowApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  PhaseFieldApp::associateSyntax(_syntax, _action_factory);
  TensorMechanicsApp::associateSyntax(_syntax, _action_factory);
  HeatConductionApp::associateSyntax(_syntax, _action_factory);
  MiscApp::associateSyntax(_syntax, _action_factory);

  #ifdef MARMOT_ENABLED
    MarmotApp::registerObjects(_factory);
    Marmot::associateSyntax(_syntax, _action_factory);
  #endif

  CrowApp::associateSyntax(_syntax, _action_factory);
}

CrowApp::~CrowApp()
{
}

extern "C" void CrowApp__registerApps() { CrowApp::registerApps(); }
void
CrowApp::registerApps()
{
  // #undef  registerApp
  // #define registerApp(name) AppFactory::instance().reg<name>(#name)

    registerApp(CrowApp);

  // #undef  registerApp
  // #define registerApp(name) AppFactory::instance().regLegacy<name>(#name)
}

extern "C" void CrowApp__registerObjects(Factory & factory) { CrowApp::registerObjects(factory); }
void
CrowApp::registerObjects(Factory & factory)
{
  // #ifdef MARMOT_ENABLED
  //   MarmotApp::registerObjects(factory);
  // #endif

  // #undef registerObject
  // #define registerObject(name) factory.reg<name>(stringifyName(name))

  // Register any custom objects you have built on the MOOSE Framework
  registerKernel(CHChemPotential);  // <- registration
  registerKernel(CHTemp);
  registerKernel(ACSinteringGrowth);
  registerKernel(ACParticleGrowth);
  registerKernel(ACParticleGrowthAniso);
  registerKernel(ElectricFieldKernel);
  registerKernel(ElectricBCKernel);
  registerKernel(VacancySourceTermKernel);
  registerKernel(RandomVacancySourceTermKernel);
  registerKernel(ConservedLangevinNoiseVoidSource);
  registerKernel(LangevinNoiseVoid);
  registerKernel(RigidBodyMotionKernel);
  //registerKernel(RadiationDefectSource);
  registerFunction(RandomNumberGeneration);

  registerMaterial(PFDiffusion);
  registerMaterial(TempDiffusion);
  registerMaterial(PFDiffusionGrowthConst);
  registerMaterial(PFDiffusionGrowth);
  registerMaterial(PFDiffusionGrowthMtrx);
  registerMaterial(PFDiffusionGrowth1);
  registerMaterial(PFEigenStrainMaterial);
  registerMaterial(PFEigenStrainMaterial1);
  registerMaterial(PFParticleGrowth);
  registerMaterial(PFTempMobility);
  registerMaterial(Mobility);
  registerMaterial(RandomVacancySourceTermMaterial);
  registerMaterial(ResistivityMaterial);
  registerMaterial(SinteringFreeEnergy);
  registerMaterial(SinteringMobility);
  registerMaterial(SinteringMtrxMobility);
  registerMaterial(SinteringDiffusion);
  registerMaterial(SinteringCoefficients);
  registerMaterial(SinteringCoefficientsAniso);
  registerMaterial(ElectricBCMat);
  //registerMaterial(RadiationDefectCreation);

  registerInitialCondition(TwoParticleGrainsIC);
  registerInitialCondition(TwoParticleDensityIC);
  registerInitialCondition(BicrystalIC);
  registerInitialCondition(MultiSmoothParticleIC);
  //registerFunction(MobilityFn);
  registerAux(RandomVoidSourceAux);
  registerPostprocessor(InterfaceAreaPostprocessor);
  registerPostprocessor(NeckAreaPostprocessor);
  // registerPostprocessor(ConservationCheck);

  registerUserObject(ConservedUniformVoidSource);

}

extern "C" void CrowApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory) { CrowApp::associateSyntax(syntax, action_factory); }
void
CrowApp::associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  // #undef registerAction
  // #define registerAction(tplt, action) action_factory.reg<tplt>(stringifyName(tplt), action)

  syntax.registerActionSyntax("PolycrystalSinteringKernelAction", "Kernels/PolycrystalSinteringKernel");
  syntax.registerActionSyntax("PolycrystalSinteringMaterialAction", "Materials/PolycrystalSinteringMaterial");
  syntax.registerActionSyntax("TwoParticleGrainsICAction", "ICs/PolycrystalICs/TwoParticleGrainsIC");
  syntax.registerActionSyntax("BicrystalICAction", "ICs/PolycrystalICs/BicrystalIC");
  syntax.registerActionSyntax("MultiSmoothParticleICAction", "ICs/PolycrystalICs/MultiSmoothParticleIC");

  registerAction(PolycrystalSinteringKernelAction, "add_kernel");
  registerAction(PolycrystalSinteringMaterialAction, "add_material");
  registerAction(TwoParticleGrainsICAction, "add_ic");
  registerAction(BicrystalICAction, "add_ic");
  registerAction(MultiSmoothParticleICAction, "add_ic");

  // #undef registerAction
  // #define registerAction(tplt, action) action_factory.regLegacy<tplt>(stringifyName(tplt), action)
}
