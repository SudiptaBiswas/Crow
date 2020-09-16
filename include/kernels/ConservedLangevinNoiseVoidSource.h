#pragma once

#include "ConservedNoiseBase.h"
#include "LangevinNoise.h"

class ConservedLangevinNoiseVoidSource : public LangevinNoise {
public:
  static InputParameters validParams();
  ConservedLangevinNoiseVoidSource(const InputParameters &parameters);

protected:
  virtual void residualSetup(){};
  virtual Real computeQpResidual();

private:
  const ConservedNoiseInterface &_noise;
  const VariableValue &_eta;
};
