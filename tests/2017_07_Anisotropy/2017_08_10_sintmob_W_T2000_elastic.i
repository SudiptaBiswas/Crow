[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  displacements = 'disp_x disp_y'
  #en_ratio = 1
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 80
  ny = 50
  nz = 0
  xmin = 0.0
  xmax = 40.0
  ymin = 0.0
  ymax = 25.0
  zmax = 0
  #uniform_refine = 2
  elem_type = QUAD4
[]

[Variables]
  [./c]
    #scaling = 10
  [../]
  [./w]
  [../]
  [./PolycrystalVariables]
  [../]
  [./disp_x]
    #scaling = 1e3
  [../]
  [./disp_y]
    #scaling = 1e3
  [../]
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = true
    generate_output = 'stress_xx stress_yy strain_xx strain_yy vonmises_stress'
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
  [./S2_11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./S2_22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./E_11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./E_22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./E2_11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./E2_22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./E0_11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./E0_22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C1_1111]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C0_1111]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C2_1111]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./euler_angle]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Functions]
  [./load]
    type = PiecewiseLinear
    y = '0.0 -0.4 -0.4'
    x = '0.0 30.0 100.0'
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
    type = SplitCHWRes
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
    args = 'c gr1   '
    f_name = E1
  [../]
  [./ElstcEn_gr1]
    type = AllenCahn
    variable = gr1
    args = 'c gr0   '
    f_name = E1
  [../]
  #[./PolycrystalElasticDrivingForce]
  #[../]
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
  [./S2_22]
    type = RankTwoAux
    variable = S2_22
    rank_two_tensor = second_stress
    index_j = 1
    index_i = 1
    block = 0
  [../]
  [./S2_11]
    type = RankTwoAux
    variable = S2_11
    rank_two_tensor = second_stress
    index_j = 0
    index_i = 0
    block = 0
  [../]
  [./E1_11]
    type = RankTwoAux
    variable = E_11
    rank_two_tensor = second_mechanical_strain
    index_j = 0
    index_i = 0
    block = 0
  [../]
  [./E1_22]
    type = RankTwoAux
    variable = E_22
    rank_two_tensor = second_mechanical_strain
    index_j = 1
    index_i = 1
    block = 0
  [../]
  [./E2_11]
    type = RankTwoAux
    variable = E2_11
    rank_two_tensor = phase1_mechanical_strain
    index_j = 0
    index_i = 0
    block = 0
  [../]
  [./E2_22]
    type = RankTwoAux
    variable = E2_22
    rank_two_tensor = phase1_mechanical_strain
    index_j = 1
    index_i = 1
    block = 0
  [../]
  [./E0_11]
    type = RankTwoAux
    variable = E0_11
    rank_two_tensor = phase0_mechanical_strain
    index_j = 0
    index_i = 0
    block = 0
  [../]
  [./E0_22]
    type = RankTwoAux
    variable = E0_22
    rank_two_tensor = phase0_mechanical_strain
    index_j = 1
    index_i = 1
    block = 0
  [../]
  [./C1_1111]
    type = RankFourAux
    variable = C1_1111
    rank_four_tensor = phase1_elasticity_tensor
    index_l = 0
    index_j = 0
    index_k = 0
    index_i = 0
    execute_on = timestep_end
  [../]
  [./C0_1111]
    type = RankFourAux
    variable = C0_1111
    rank_four_tensor = phase0_elasticity_tensor
    index_l = 0
    index_j = 0
    index_k = 0
    index_i = 0
    execute_on = timestep_end
  [../]
  [./C2_1111]
    type = RankFourAux
    variable = C2_1111
    rank_four_tensor = second_elasticity_tensor
    index_l = 0
    index_j = 0
    index_k = 0
    index_i = 0
    execute_on = timestep_end
  [../]
  [./euler_angle]
    type = OutputEulerAngles
    variable = euler_angle
    euler_angle_provider = euler_angle_file
    grain_tracker = grain_tracker
    output_euler_angle = 'phi1'
    execute_on = 'initial timestep_end'
  [../]
[]

[BCs]
  [./flux]
    type = CahnHilliardFluxBC
    variable = w
    boundary = 'top bottom left right'
    flux = '0 0 0'
    mob_name = D
    args = 'c'
  [../]
  [./bottom_y]
    type = PresetBC
    variable = disp_y
    boundary = bottom
    value = 0
  [../]
  [./left_x]
    type = PresetBC
    variable = disp_x
    boundary = left
    value = 0
  [../]
  [./right_x]
    type = PresetBC
    variable = disp_x
    boundary = right
    value = 0
  [../]
  [./top_y]
    type = FunctionPresetBC
    variable = disp_y
    boundary = top
    function = load
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
    outputs = exodus
  [../]
  #[./constant_mat]
  #  type = GenericConstantMaterial
  #  block = 0
  #  prop_names = '  A         B  kappa_op    kappa_c  L'
  #  prop_values = '19.94   2.14   6.43       11.04    3.42'
  #  #prop_names = '  A    B  '
  #  #prop_values = '16.0 1.0 '
  #[../]
  [./coeff]
    type = SinteringCoefficients
    block = 0
    T = 2000.0
    int_width = 2
    GBmob0 = 3.2e-7
    Qgbm = 2.6
    surface_energy = 5.82e-21
    GB_energy = 4.29e-21
    length_scale = 1e-08
    time_scale = 1e-04
    energy_scale = 1e-05
    outputs = exodus
  [../]
  [./mob]
    type = SinteringMobility
    T = 2000.0
    int_width = 2
    Qv = 5.22
    Qvc = 2.3
    Qgb = 3.05
    Qs = 3.14
    Dgb0 = 1.41e-5
    Dsurf0 = 4.0e-4
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
    prefactor = 0.1
    outputs = exodus
  [../]
  #elastic properties for phase with c = 1
  [./elasticity_tensor_phase1]
    type = ComputePolycrystalElasticityTensor
    base_name = phase1
    block = 0
    grain_tracker = grain_tracker
    length_scale = 1.0
    pressure_scale = 1.0
  [../]
  #[./elasticity_tensor_phase1]
  #  type = ComputeElasticityTensor
  #  base_name = phase1
  #  block = 0
  #  fill_method = symmetric_isotropic
  #  C_ijkl = '1210.27 950.93'
  #[../]
  #elastic properties for phase with c = 0
  [./elasticity_tensor_phase0]
    type = ComputeElasticityTensor
    base_name = phase0
    block = 0
    fill_method = symmetric_isotropic
    C_ijkl = '2.0 2.0'
  [../]

  [./smallstrain_phase1]
    type = ComputeSmallStrain
    base_name = phase1
    block = 0
    displacements = 'disp_x disp_y'
  [../]
  [./stress_phase1]
    type = ComputeLinearElasticStress
    base_name = phase1
    block = 0
  [../]
  [./elstc_en_phase1]
    type = ElasticEnergyMaterial
    base_name = phase1
    f_name = Fe1
    block = 0
    args = 'c gr0 gr1'
    derivative_order = 2
  [../]

  [./smallstrain_phase0]
    type = ComputeSmallStrain
    base_name = phase0
    block = 0
    displacements = 'disp_x disp_y'
  [../]
  [./stress_phase0]
    type = ComputeLinearElasticStress
    base_name = phase0
    block = 0
  [../]
  [./elstc_en_phase0]
    type = ElasticEnergyMaterial
    base_name = phase0
    f_name = Fe0
    block = 0
    args = 'c'
    derivative_order = 2
  [../]
  #switching function for elastic energy calculation
  [./switching_phase1]
    type = SwitchingFunctionMaterial
    block = 0
    function_name = h1
    eta = c
    h_order = SIMPLE
    outputs = exodus
    output_properties = 'h1'
  [../]
  [./switching_phase0]
    type = DerivativeParsedMaterial
    block = 0
    f_name = h0
    material_property_names = 'h1'
    function = (1-h1)
    args = c
  [../]
  [./elasticity_tensor]
    type = CompositeElasticityTensor
    block = 0
    base_name = second
    args = 'c gr0 gr1'
    tensors = 'phase0   phase1'
    weights = 'h0       h1'
  [../]

  [./smallstrain]
    type = ComputeSmallStrain
    block = 0
    base_name = second
    displacements = 'disp_x disp_y'
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    block = 0
    base_name = second
  [../]
  [./elstc_en]
    type = ElasticEnergyMaterial
    f_name = E
    base_name = second
    block = 0
    args = 'c gr0 gr1'
    derivative_order = 2
    outputs = exodus
    output_properties = 'E'
  [../]
  # gloabal Stress
  [./global_stress]
    type = TwoPhaseStressMaterial
    block = 0
    base_A = phase1
    base_B = phase0
    h = h1
  [../]
  [./total_elastc_en]
    type = DerivativeTwoPhaseMaterial
    block = 0
    h = h1
    g = 0.0
    W = 0.0
    eta = c
    args = 'gr0 gr1'
    f_name = E1
    fa_name = Fe1
    fb_name = Fe0
    derivative_order = 2
    outputs = exodus
    output_properties = 'E1'
  [../]
  # glo
  # total energy
  [./sum]
    type = DerivativeSumMaterial
    block = 0
    sum_materials = 'S E1'
    args = 'c gr0 gr1'
    derivative_order = 2
    outputs = exodus
    output_properties = 'F'
  [../]
[]

[UserObjects]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = test.tex
  [../]
  [./grain_tracker]
    type = GrainTrackerElasticity
    threshold = 0.1
    use_single_map = false
    enable_var_coloring = true
    condense_map_info = true
    connecting_threshold = 0.05
    compute_var_to_feature_map = true
    execute_on = TIMESTEP_BEGIN
    flood_entity_type = ELEMENTAL
    outputs = none
    fill_method = symmetric_isotropic
    C_ijkl = '1210.27 950.93'
    #fill_method = symmetric9
    #C_ijkl = '1.27e3 0.708e3 0.708e3 1.27e3 0.708e3 1.27e3 0.7355e3 0.7355e3 0.7355e3'
    euler_angle_provider = euler_angle_file
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
    mat_prop = F
  [../]
  [./dofs]
    type = NumDOFs
  [../]
  [./tstep]
    type = TimestepSize
  [../]
  [./s11]
    type = ElementIntegralVariablePostprocessor
    variable = stress_xx
  [../]
  [./s22]
    type = ElementIntegralVariablePostprocessor
    variable = stress_yy
  [../]
  [./chem_free_en]
    type = ElementIntegralMaterialProperty
    mat_prop = S
  [../]
  [./elstc_en]
    type = ElementIntegralMaterialProperty
    mat_prop = E
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
  [./gb_area]
    type = GrainBoundaryArea
  [../]
  [./neck]
    type = NeckAreaPostprocessor
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    coupled_groups = 'c,w c,gr0,gr1,disp_x,disp_y'
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  scheme = BDF2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   ilu      1'
  l_max_its = 20
  nl_max_its = 20
  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-06
  l_tol = 1e-03
  end_time = 100
  #dt = 0.01
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    growth_factor = 1.2
  [../]
[]

[Adaptivity]
  marker = bound_adapt
  max_h_level = 1
  [./Indicators]
    [./error]
      type = GradientJumpIndicator
      variable = bnds
    [../]
  [../]
  [./Markers]
    [./bound_adapt]
      type = ValueRangeMarker
      lower_bound = 0.005
      upper_bound = 0.93
      variable = bnds
    [../]
  [../]
[]

[Outputs]
  print_linear_residuals = true
  csv = true
  gnuplot = true
  print_perf_log = true
  exodus = true
  [./console]
    type = Console
    perf_log = true
  [../]
  #[./exodus]
  #  type = Exodus
  #  elemental_as_nodal = true
  #[../]
[]

[ICs]
  [./ic_gr1]
    int_width = 2.0
    x1 = 25.5
    y1 = 10.0
    radius = 8.0
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./multip]
    x_positions = '11.5 25.5'
    int_width = 2.0
    z_positions = '0 0'
    y_positions = '13.0 10.0'
    radii = '6.0 8.0'
    3D_spheres = false
    outvalue = 0.001
    variable = c
    invalue = 0.999
    type = SpecifiedSmoothCircleIC
    block = 0
  [../]
  [./ic_gr0]
    int_width = 2.0
    x1 = 11.5
    y1 = 13.0
    radius = 6.0
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
    type = SmoothCircleIC
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
