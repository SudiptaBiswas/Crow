[Mesh]
  type = FileMesh
  file = blunt_crack.e
[]

[Variables]
  [./disp_x]
    block = 1
  [../]
  [./disp_y]
    block = 1
  [../]
  [./c]
    block = 1
  [../]
  [./b]
    block = 1
  [../]
[]

[AuxVariables]
  [./resid_x]
    block = 1
  [../]
  [./resid_y]
    block = 1
  [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  [../]
  [./peeq]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  [../]
  [./fp_xx]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  [../]
  [./fp_yy]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  [../]
[]

[Functions]
  [./tfunc]
    type = ParsedFunction
    value = '0.0001*t'
  [../]
[]

[Kernels]
  [./pfbulk]
    type = PFFracBulkRate
    variable = c
    block = 1
    l = 0.005
    beta = b
    visco =1
    gc_prop_var = 'gc_prop'
    G0_var = 'G0'
    dG0_dstrain_var = 'dG0_dstrain'
    #disp_x = disp_x
    #disp_y = disp_y
  [../]
  [./solid_x]
    type = StressDivergencePFFracTensors
    variable = disp_x
    displacements = 'disp_x disp_y'
    component = 0
    block = 1
    save_in = resid_x
    c = c
    use_displaced_mesh = true
  [../]
  [./solid_y]
    type = StressDivergencePFFracTensors
    variable = disp_y
    displacements = 'disp_x disp_y'
    component = 1
    block = 1
    save_in = resid_y
    c = c
    use_displaced_mesh = true
  [../]
  [./dcdt]
    type = TimeDerivative
    variable = c
    block = 1
  [../]
  [./pfintvar]
    type = Reaction
    variable = b
    block = 1
  [../]
  [./pfintcoupled]
    type = PFFracCoupledInterface
    variable = b
    c = c
    block = 1
  [../]
[]

[AuxKernels]
  [./stress_yy]
    type = RankTwoAux
    variable = stress_yy
    rank_two_tensor = stress
    index_j = 1
    index_i = 1
    execute_on = timestep_end
    block = 1
  [../]
  [./peeq]
    type = MaterialRealAux
    variable = peeq
    property = ep_eqv
    execute_on = timestep_end
    block = 1
  [../]
  [./fp_xx]
    type = RankTwoAux
    variable = fp_xx
    rank_two_tensor = fp
    index_j = 0
    index_i = 0
    execute_on = timestep_end
    block = 1
  [../]
  [./fp_yy]
    type = RankTwoAux
    variable = fp_yy
    rank_two_tensor = fp
    index_j = 1
    index_i = 1
    execute_on = timestep_end
    block = 1
  [../]
[]

[BCs]
  [./ydisp]
    type = FunctionPresetBC
    variable = disp_y
    boundary = 2
    function = tfunc
  [../]
  [./yfix]
    type = PresetBC
    variable = disp_y
    boundary = 1
    value = 0
  [../]
  [./xfix]
    type = PresetBC
    variable = disp_x
    boundary = '1 2'
    value = 0
  [../]
[]

[UserObjects]
  [./flowstress]
    type = HEVPLinearHardening
    yield_stress = 0.3
    slope = 1
    intvar_prop_name = ep_eqv
  [../]
  [./flowrate]
    type = HEVPFlowRatePowerLawJ2
    reference_flow_rate = 0.0001
    flow_rate_exponent = 10.0
    flow_rate_tol = 1
    strength_prop_name = flowstress
  [../]
  [./ep_eqv]
     type = HEVPEqvPlasticStrain
     intvar_rate_prop_name = ep_eqv_rate
  [../]
  [./ep_eqv_rate]
     type = HEVPEqvPlasticStrainRate
     flow_rate_prop_name = flowrate
  [../]
[]

[Materials]
  [./pfbulkmat]
    type = PFFracBulkRateMaterial
    block = 1
    gc = 1e-3
  [../]
  [./strain]
    type = ComputeFiniteStrain
    block = 1
    displacements = 'disp_x disp_y'
  [../]
  [./viscop_damage]
    type = HyperElasticPhaseFieldIsoDamage
    block = 1
    resid_abs_tol = 1e-18
    resid_rel_tol = 1e-8
    maxiters = 50
    max_substep_iteration = 5
    flow_rate_user_objects = 'flowrate'
    strength_user_objects = 'flowstress'
    internal_var_user_objects = 'ep_eqv'
    internal_var_rate_user_objects = 'ep_eqv_rate'
    numerical_stiffness = false
    damage_stiffness = 1e-8
    c = c
  [../]
  [./elasticity_tensor]
    type = ComputeElasticityTensor
    block = 1
    C_ijkl = '120.0 80.0'
    fill_method = symmetric_isotropic
  [../]
[]

[Postprocessors]
  [./resid_x]
    type = NodalSum
    variable = resid_x
    boundary = 2
  [../]
  [./resid_y]
    type = NodalSum
    variable = resid_y
    boundary = 2
  [../]
  [./fp_xx]
    type = ElementAverageValue
    variable = fp_xx
    block = 'ANY_BLOCK_ID 1'
  [../]
  [./fp_yy]
    type = ElementAverageValue
    variable = fp_yy
    block = 'ANY_BLOCK_ID 1'
  [../]
[]

[Preconditioning]
  active = 'smp'
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient

  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly       lu           1'

  nl_rel_tol = 1e-3
  l_max_its = 40
  nl_max_its = 10

  dt = 1
  dtmin = 1.e-4
  end_time = 1000
#  num_steps = 2
[]

[Outputs]

  interval = 1
  exodus = true
  csv = true

  [./console]
     type = Console
     execute_on = nonlinear
#     output_linear = false
     interval = 1
  [../]
[]
