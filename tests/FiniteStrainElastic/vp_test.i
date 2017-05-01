[Mesh]
  type = GeneratedMesh
  dim = 3
  elem_type = HEX8
  nx = 10
  ny = 10
  nz = 10
  displacements = 'ux uy uz'
[]

[Variables]
  [./ux]
    block = 0
  [../]
  [./uy]
    block = 0
  [../]
  [./uz]
    block = 0
  [../]
[]

[Kernels]
  [./TensorMechanics]
    displacements = 'ux uy uz'
    use_displaced_mesh = true
  [../]
[]

[AuxVariables]
  [./stress_zz]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./peeq]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./fp_zz]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
[]

[AuxKernels]
  [./stress_zz]
    type = RankTwoAux
    variable = stress_zz
    rank_two_tensor = stress
    index_j = 2
    index_i = 2
    execute_on = timestep_end
    block = 0
  [../]
  [./fp_zz]
    type = RankTwoAux
    variable = fp_zz
    rank_two_tensor = fp
    index_j = 2
    index_i = 2
    execute_on = timestep_end
    block = 0
  [../]
  [./peeq]
    type = MaterialRealAux
    variable = peeq
    property = ep_eqv
    execute_on = timestep_end
    block = 0
  [../]
[]

[BCs]
  [./symmy]
    type = PresetBC
    variable = uy
    boundary = bottom
    value = 0
  [../]
  [./symmx]
    type = PresetBC
    variable = ux
    boundary = left
    value = 0
  [../]
  [./symmz]
    type = PresetBC
    variable = uz
    boundary = back
    value = 0
  [../]
  [./tdisp]
    type = FunctionPresetBC
    variable = uz
    boundary = front
    function = '0.0001*t'
  [../]
[]

[UserObjects]
  [./flowstress]
    type = VPStrength
    intvar_prop_name = ep_eqv
    slope = 1.0
    yield = 10.0
  [../]
  [./flowrate]
    type = ViscoplasticFlowRate
    #reference_flow_rate = 0.0001
    flow_rate_tol = 1
    strength_prop_name = flowstress
    flow_rate_prop_name = flowrate
    intvar_prop_name = ep_eqv
    intvar_prop_tensor_name = intvar_tensor
    intvar_rate_prop_name = ep_eqv_rate
    intvar_rate_prop_tensor_name = intvarrate_tensor
    hardening_multiplier = 1
  [../]
  [./ep_eqv]
     type = VPHardening
     intvar_rate_prop_name = ep_eqv_rate
  [../]
  [./ep_eqv_rate]
     type = VPIsotropicHardeningRate
     flow_rate_prop_name = flowrate
     intvar_prop_name = ep_eqv
     intvar_prop_tensor_name = intvar_tensor
     intvar_rate_prop_name = ep_eqv_rate
     intvar_rate_prop_tensor_name = intvarrate_tensor
     strength_prop_name = flowstress
     hardening_exponent = 8.0
     hardening_multiplier = 1
  [../]
  [./intvar_tensor]
    type = VPTensorHardening
    intvar_rate_prop_name = intvarrate_tensor
  [../]
  [./intvarrate_tensor]
    type = VPKinematicHardeningRate
    flow_rate_prop_name = flowrate
    intvar_prop_name = ep_eqv
    intvar_prop_tensor_name = intvar_tensor
    intvar_rate_prop_name = ep_eqv_rate
    intvar_rate_prop_tensor_name = intvarrate_tensor
    strength_prop_name = flowstress
    flow_rate_uo = flowrate
  [../]
[]

[Materials]
  [./strain]
    type = ComputeFiniteStrain
    block = 0
    displacements = 'ux uy uz'
  [../]
  [./viscop]
    type = FiniteStrainViscoPlastic
    block = 0
    resid_abs_tol = 1e-8
    resid_rel_tol = 1e-6
    maxiters = 50
    max_substep_iteration = 8
    flow_rate_user_objects = 'flowrate'
    strength_user_objects = 'flowstress'
    internal_var_user_objects = 'ep_eqv'
    internal_var_rate_user_objects = 'ep_eqv_rate'
    internal_var_tensor_user_objects = 'intvar_tensor'
    internal_var_tensor_rate_user_objects = 'intvarrate_tensor'
  [../]
  #[./elasticity_tensor]
  #  type = ComputeElasticityTensor
  #  block = 0
  #  C_ijkl = '2.8e5 1.2e5 1.2e5 2.8e5 1.2e5 2.8e5 0.8e5 0.8e5 0.8e5'
  #  fill_method = symmetric9
  #[../]
  [./elasticity_tensor]
    type = ComputeElasticityTensor
    C_ijkl = '30.0 36.0'
    fill_method = symmetric_isotropic
  [../]
[]

[Postprocessors]
  [./stress_zz]
    type = ElementAverageValue
    variable = stress_zz
    block = 'ANY_BLOCK_ID 0'
  [../]
  [./fp_zz]
    type = ElementAverageValue
    variable = fp_zz
    block = 'ANY_BLOCK_ID 0'
  [../]
  [./peeq]
    type = ElementAverageValue
    variable = peeq
    block = 'ANY_BLOCK_ID 0'
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  #dt = 0.02
  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'
  #petsc_options_iname = -pc_hypre_type
  #petsc_options_value = boomerang
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  nl_rel_tol = 1e-8
  l_tol = 1e-04
  l_max_its = 10
  nl_max_its = 10
  dt = 0.1
  dtmin = 1e-4
  dtmax = 10.0
  num_steps = 10000
[]

[Outputs]
  file_base = one_elem
  exodus = true
  csv = false
[]

#[Problem]
#  use_legacy_uo_initialization = false
#[]
