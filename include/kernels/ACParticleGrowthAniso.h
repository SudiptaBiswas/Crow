#ifndef ACPARTICLEGROWTHANISO_H
#define ACPARTICLEGROWTHANISO_H

#include "ACBulk.h"

//Forward Declarations
class ACParticleGrowthAniso;
class AnisoGBEnergyUserObject;

template<>
InputParameters validParams<ACParticleGrowthAniso>();

/**
 * This kernel calculates the residual for grain growth during sintering.
 * It calculates the residual of the ith order parameter, and the values of
 * all other order parameters are coupled variables and are stored in vals.
 */
class ACParticleGrowthAniso : public ACBulk<Real>
{
public:
  ACParticleGrowthAniso(const InputParameters & parameters);

protected:
  virtual Real computeDFDOP(PFFunctionType type);
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  const VariableValue & _c;
  unsigned int _c_var;
  unsigned int _op;
  unsigned int _op_num;

  std::vector<const VariableValue *> _vals;
  std::vector<const VariableGradient *> _grad_vals;
  std::vector<unsigned int> _vals_var;
  const AnisoGBEnergyUserObject & _aniso_GB_energy;

  //const MaterialProperty<Real> & _L;
  //const MaterialProperty<Real> & _B;

  Real _length_scale;
  Real _int_width;

  unsigned int _ncrys;

};

#endif //ACPARTICLEGROWTHANISO_H
