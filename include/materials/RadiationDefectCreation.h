#ifndef RADIATIONDEFECTCREATION_H
#define RADIATIONDEFECTCREATION_H

#include "Material.h"

//Forward Declarations
class RadiationDefectCreation;

template<>
InputParameters validParams<RadiationDefectCreation>();

/**
 * This material computes the amount the vacancy and interstitial concentrations will increase
 * at each quadrature point due to radiation
 */
class RadiationDefectCreation : public Material
{
public:
  RadiationDefectCreation(const InputParameters & parameters);

protected:
  virtual void timestepSetup();
  virtual void computeQpProperties();

  const unsigned int _mesh_dimension;

  /// Co-ordinates/position of neutron impact locations
  std::vector<Point> _NImpPos;

  /// Order parameter used to make sure no vacancies/interstitials are created within void phase
  const VariableValue & _eta;

  /// Magnitude of vacancy/interstitial source rate
  Real _Vg;

  // point _p1, _p2;
  Point _bottom_left;
  Point _top_right;
  Point _range;

  bool _periodic;
  /// Parameter for specifying whether fission rate will be coupled or not
  bool _coupled_rate;

  int _input_num_defects;
  int _num_defects;

  Real _input_rate;
  /// For a random number of defects, the expected value per unit area/volume per unit time
  const PostprocessorValue & _expected_num;

  Real _mag;
  /// Ratio bias to vacancy creation over interstitial creation; >1 means more vacancies generated
  Real _vac_bias;
  Real _spacing;
  /// Modification to fission rate to make it work better
  Real _rate_mult;

  /// Material property showing increase in vacancy concentration
  MaterialProperty<Real> & _interstitial_increase;
  /// Material property showing increase in interstitial concentration
  MaterialProperty<Real> & _vacancy_increase;

};

#endif //RADIATIONDEFECTCREATION_H
