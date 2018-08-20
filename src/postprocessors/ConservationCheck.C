/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

// #include "ConservationCheck.h"
// #include "FeatureVolumeVectorPostprocessor.h"
// #include "GrainTrackerInterface.h"
// #include "GrainForceAndTorqueInterface.h"
//
// template<>
// InputParameters validParams<ConservationCheck>()
// {
//   InputParameters params =
//   validParams<ElementIntegralVariablePostprocessor>();
//   params.addParam<Real>("translation_constant", 1.0, "constant value
//   characterizing grain translation");
//   params.addParam<Real>("rotation_constant", 1.0, "constant value
//   characterizing grain rotation");
//   params.addParam<UserObjectName>("grain_tracker_object", "userobject for
//   getting volume and center of mass of grains");
//   params.addParam<VectorPostprocessorName>("grain_volumes", "The feature
//   volume VectorPostprocessorValue.");
//   params.addParam<UserObjectName>("grain_force", "userobject for getting
//   force and torque acting on grains"); params.addCoupledVarWithAutoBuild("v",
//   "var_name_base", "op_num", "Array of coupled variables"); return params;
// }
//
// ConservationCheck::ConservationCheck(const InputParameters & parameters) :
//     ElementIntegralVariablePostprocessor(parameters),
//     VectorPostprocessorInterface(this),
//     _grain_tracker(getUserObject<GrainTrackerInterface>("grain_tracker_object")),
//     _grain_volumes(getVectorPostprocessorValue("grain_volumes",
//     "feature_volumes")),
//     _grain_force_torque(getUserObject<GrainForceAndTorqueInterface>("grain_force")),
//     _grain_forces(_grain_force_torque.getForceValues()),
//     _grain_torques(_grain_force_torque.getTorqueValues()),
//     _mt(getParam<Real>("translation_constant")),
//     _mr(getParam<Real>("rotation_constant")),_op_num(coupledComponents("v")),
//     _vals(_op_num)
// {
//   for (unsigned int i = 0; i < _op_num; ++i)
//     _vals[i] = &coupledValue("v", i);
// }
//
// Real
// ConservationCheck::computeQpIntegral()
// {
//   _velocity_advection = 0.0;
//   _grain_ids = _grain_tracker.getVarToFeatureVector(_current_elem->id());
//
//   for (auto i = beginIndex(_grain_ids); i < _grain_ids.size(); ++i)
//   {
//     auto grain_id = _grain_ids[i];
//     if (grain_id != FeatureFloodCount::invalid_id)
//     {
//       mooseAssert(grain_id < _grain_volumes.size(), "grain_id out of
//       bounds"); const auto volume = _grain_volumes[grain_id]; const auto
//       centroid = _grain_tracker.getGrainCentroid(grain_id); const auto force
//       = _mt / volume * _grain_forces[grain_id]; const auto torque = _mr /
//       volume * (_grain_torques[grain_id].cross(_current_elem->centroid() -
//       centroid));
//
//       _velocity_advection += (force + torque) * (*_vals[i])[_qp];
//     }
//   }
//   // RealVectorValue v(1.0, 1.0, 1.0);
//   // return _velocity_advection * v;
//   return _velocity_advection * _grad_u[_qp];
// }
