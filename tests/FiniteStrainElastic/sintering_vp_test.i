[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  displacements = 'ux uy'
  block = 0
  #en_ratio = 1
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 80
  ny = 40
  nz = 0
  xmin = 0.0
  xmax = 40.0
  ymin = 0.0
  ymax = 20.0
  zmax = 0
  #uniform_refine = 2
  elem_type = QUAD4
[]



[Variables]
  [./c]
  [../]
  [./w]
  [../]
  [./PolycrystalVariables]
  [../]
  [./ux]
  [../]
  [./uy]
  [../]
[]

[ICs]
  [./ic_gr1]
    int_width = 2.0
    x1 = 25.0
    y1 = 10.0
    radius = 7.4
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./multip]
    x_positions = '10.0 25.0'
    int_width = 2.0
    z_positions = '0 0'
    y_positions = '10.0 10.0 '
    radii = '7.4 7.4'
    3D_spheres = false
    outvalue = 0.001
    variable = c
    invalue = 0.999
    type = SpecifiedSmoothCircleIC
    block = 0
  [../]
  [./ic_gr0]
    int_width = 2.0
    x1 = 10.0
    y1 = 10.0
    radius = 7.4
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
    type = SmoothCircleIC
  [../]
[]

[Kernels]
  [./cres]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa_c
    w = w
    f_name = F
    args = 'gr0 gr1'
  [../]
  [./wres]
    type = SplitCHWResAniso
    variable = w
    mob_name = D
  [../]
  [./time]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./PolycrystalSinteringKernel]
    c = c
    consider_rigidbodymotion = false
    #grain_force = grain_force
    #grain_tracker_object = grain_center
    #grain_volumes = grain_volumes
    #translation_constant = 10.0
    #rotation_constant = 1.0
  [../]
  [./ElstcEn_gr0]
    type = AllenCahn
    variable = gr0
    args = 'c gr1 '
    f_name = E
  [../]
  [./ElstcEn_gr1]
    type = AllenCahn
    variable = gr1
    args = 'c gr0'
    f_name = E
  [../]
  [./TensorMechanics]
    use_displaced_mesh = true
  [../]
[]

[AuxVariables]
  [./bnds]
  [../]
  [./total_en]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./gradc_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./gradc_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./peeq]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./fp_yy]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
[]

[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    v = 'gr0 gr1'
  [../]
  [./Total_en]
    type = TotalFreeEnergy
    variable = total_en
    kappa_names = 'kappa_c kappa_op kappa_op'
    interfacial_vars = 'c  gr0 gr1'
  [../]
  [./gradc_x]
    type = VariableGradientComponent
    variable = gradc_x
    gradient_variable = c
    component = x
  [../]
  [./gradc_y]
    type = VariableGradientComponent
    variable = gradc_y
    gradient_variable = c
    component = y
  [../]
  [./stress_xx]
    type = RankTwoAux
    variable = stress_xx
    rank_two_tensor = stress
    index_j = 0
    index_i = 0
    execute_on = timestep_end
    block = 0
  [../]
  [./stress_yy]
    type = RankTwoAux
    variable = stress_yy
    rank_two_tensor = stress
    index_j = 1
    index_i = 1
    execute_on = timestep_end
    block = 0
  [../]
  [./fp_yy]
    type = RankTwoAux
    variable = fp_yy
    rank_two_tensor = fp
    index_j = 1
    index_i = 1
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

[Functions]
  [./load]
    type = PiecewiseLinear
    y = '0.0 -1.5 -2.0'
    x = '0.0 30.0 500.0'
  [../]
[]

[BCs]
  [./bottom_y]
    type = PresetBC
    variable = uy
    boundary = bottom
    value = 0
  [../]
  [./left_x]
    type = PresetBC
    variable = ux
    boundary = left
    value = 0
  [../]
  [./right_x]
    type = PresetBC
    variable = ux
    boundary = right
    value = 0
  [../]
  [./top_y]
    type = FunctionPresetBC
    variable = uy
    boundary = top
    function = load
  [../]
  #[./tdisp]
  #  type = FunctionPresetBC
  #  variable = uz
  #  boundary = front
  #  function = '0.0001*t'
  #[../]
[]

[UserObjects]
  [./flowstress]
    type = VPStrength
    intvar_prop_name = ep_eqv
    slope = 1.0
    yield = 0.3
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
  [./free_energy]
    type = SinteringFreeEnergy
    block = 0
    c = c
    v = 'gr0 gr1'
    f_name = S
    derivative_order = 2
    #outputs = console
  [../]
  [./constant_mat]
    type = GenericConstantMaterial
    prop_names = '  A         B       kappa_op    kappa_c L'
    prop_values = '19.9728   2.1221   6.366340   8.706906 10.0'
  [../]
  [./mob]
    type = SinteringMtrxMobility
    T = 1500.0
    int_width = 2
    GBmob0 = 3.986e-6
    Qv = 2.0
    Qgb = 4.143
    Qs = 3.14
    Qgbm = 0.94
    Dgb0 = 4.0e-4
    Dsurf0 = 1.41e-5
    Dvap0 = 4.0e-6
    Dvol0 = 4.0e-6
    c = c
    v = 'gr0 gr1'
    Vm = 1.5829e-29
    length_scale = 1e-08
    time_scale = 1e-4
    bulkindex = 1.0
    surfindex = 1.0
    gbindex = 1.0
    outputs = exodus
  [../]
  [./elasticity_tensor_phase1]
    type = ComputeElasticityTensor
    fill_method = symmetric_isotropic
    C_ijkl = '35.46 30.141'
    base_name = phase1
  [../]
  [./elasticity_tensor_phase0]
    type = ComputeElasticityTensor
    base_name = phase0
    fill_method = symmetric_isotropic
    C_ijkl = '2.0 2.0'
  [../]
  [./switching_phase1]
    type = SwitchingFunctionMaterial
    function_name = h1
    eta = c
    h_order = SIMPLE
  [../]
  [./switching_phase0]
    type = DerivativeParsedMaterial
    f_name = h0
    material_property_names = 'h1'
    function = (1-h1)
    args = c
  [../]
  [./elasticity_tensor]
    type = CompositeElasticityTensor
    args = 'c gr0 gr1'
    tensors = 'phase0   phase1'
    weights = 'h0       h1'
  [../]
  [./strain]
    type = ComputeFiniteStrain
  [../]
  [./viscop]
    type = FiniteStrainViscoPlastic
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
  [./elstc_en]
    type = ElasticEnergyMaterial
    f_name = E
    args = 'c gr0 gr1'
    derivative_order = 2
  [../]
  [./plastic_en]
    type = PlasticEnergyMaterial
    #plasticity_variable = 'flow_rate'
    f_name = P
    A = 1.0
    H = 1.0
    C = 1.0
    args = 'c gr0 gr1'
    yield = 0.3
    flow_rate_prop_name = flowrate
    intvar_prop_name = ep_eqv
    intvar_prop_tensor_name = intvar_tensor
    flow_rate_user_object = 'flowrate'
    strength_user_object = 'flowstress'
    internal_var_user_object = 'ep_eqv'
    internal_var_rate_user_object = 'ep_eqv_rate'
    internal_var_tensor_user_object = 'intvar_tensor'
    internal_var_tensor_rate_user_object = 'intvarrate_tensor'
    derivative_order = 2
  [../]
  [./sum]
    type = DerivativeSumMaterial
    sum_materials = 'S E P'
    args = 'c gr0 gr1'
    derivative_order = 2
  [../]
[]

[Postprocessors]
  [./elem_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
  [../]
  [./elem_bnds]
    type = ElementIntegralVariablePostprocessor
    variable = bnds
  [../]
  [./total_energy]
    type = ElementIntegralVariablePostprocessor
    variable = total_en
  [../]
  [./free_en]
    type = ElementIntegralMaterialProperty
    mat_prop = S
  [../]
  [./elastic_en]
    type = ElementIntegralMaterialProperty
    mat_prop = E
  [../]
  [./plastic_en]
    type = ElementIntegralMaterialProperty
    mat_prop = P
  [../]
  [./dofs]
    type = NumDOFs
  [../]
  [./tstep]
    type = TimestepSize
  [../]
  [./run_time]
    type = RunTime
    time_type = active
  [../]
  [./int_area]
    type = InterfaceAreaPostprocessor
    variable = c
  [../]
  [./grain_size_gr0]
    type = ElementIntegralVariablePostprocessor
    variable = gr0
  [../]
  [./grain_size_gr1]
    type = ElementIntegralVariablePostprocessor
    variable = gr1
  [../]
  [./grain_avg]
    type = ElementIntegralVariablePostprocessor
    variable = bnds
  [../]
  [./gb_area]
    type = GrainBoundaryArea
  [../]
  [./stress_yy]
    type = ElementAverageValue
    variable = stress_yy
  [../]
  [./fp_yy]
    type = ElementAverageValue
    variable = fp_yy
  [../]
  [./peeq]
    type = ElementAverageValue
    variable = peeq
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    coupled_groups = 'c,w c,gr0,gr1 ux,uy'
  [../]
[]

[Executioner]
  type = Transient
  scheme = BDF2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  l_max_its = 20
  nl_max_its = 20
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-08
  l_tol = 1e-04
  dtmin = 1e-4
  dtmax = 10.0
  end_time = 500
  #dt = 0.01
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    growth_factor = 1.2
  [../]
[]

[Adaptivity]
  marker = bound_adapt
  max_h_level = 2
  [./Indicators]
    [./error]
      type = GradientJumpIndicator
      variable = bnds
    [../]
  [../]
  [./Markers]
    [./bound_adapt]
      type = ValueRangeMarker
      lower_bound = 0.01
      upper_bound = 0.99
      variable = bnds
    [../]
  [../]
[]


[Outputs]
  print_linear_residuals = true
  csv = true
  gnuplot = true
  print_perf_log = true
  [./console]
    type = Console
    perf_log = true
  [../]
  [./exodus]
    type = Exodus
    elemental_as_nodal = true
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
