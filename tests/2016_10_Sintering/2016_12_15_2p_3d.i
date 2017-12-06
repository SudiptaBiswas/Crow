[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  block = 0
  int_width = 2.0
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 60
  ny = 40
  nz = 40
  xmax = 130.0
  ymax = 75.0
  zmax = 75.0
  elem_type = HEX8
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
  [./PolycrystalVariables]
  [../]
[]

[AuxVariables]
  [./bnds]
  [../]
  [./total_en]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./unique_grains]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./var_indices]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./centroids]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./grad_eta0_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
    #order = CONSTANT
    #amily = MONOMIAL
  [./grad_eta0_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./grad_eta1_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./grad_eta1_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./cres]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa_c
    w = w
    f_name = F
    args = 'gr0 gr1   '
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
    anisotropic = false
  [../]
[]

[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    v = 'gr0 gr1   '
  [../]
  [./Total_en]
    type = TotalFreeEnergy
    variable = total_en
    kappa_names = 'kappa_c kappa_op kappa_op'
    interfacial_vars = 'c  gr0 gr1    '
  [../]
  [./unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    flood_counter = grain_center
    field_display = UNIQUE_REGION
    execute_on = timestep_begin
  [../]
  [./var_indices]
    type = FeatureFloodCountAux
    variable = var_indices
    flood_counter = grain_center
    field_display = VARIABLE_COLORING
    execute_on = timestep_begin
  [../]
  [./centroids]
    type = FeatureFloodCountAux
    variable = centroids
    execute_on = timestep_begin
    field_display = CENTROID
    flood_counter = grain_center
  [../]
  [./grad_eta0_x]
    type = VariableGradientComponent
    component = x
    gradient_variable = gr0
    variable = grad_eta0_x
  [../]
  [./grad_eta0_y]
    type = VariableGradientComponent
    component = y
    gradient_variable = gr0
    variable = grad_eta0_y
  [../]
  [./grad_eta1_x]
    type = VariableGradientComponent
    component = x
    gradient_variable = gr1
    variable = grad_eta1_x
  [../]
  [./grad_eta1_y]
    type = VariableGradientComponent
    component = y
    gradient_variable = gr1
    variable = grad_eta1_y
  [../]
[]

[Materials]
  [./free_energy]
    type = SinteringFreeEnergy
    block = 0
    c = c
    v = 'gr0 gr1   '
    f_name = F
    derivative_order = 2
  [../]
  [./mob]
    type = SinteringMtrxMobility
    T = 2100.0
    int_width = 5
    Dvol0 = 4e-6
    GBmob0 = 3.986e-6
    Qv = 2.0
    Qs = 3.14
    Qgb = 4.14
    Dsurf0 = 1.41e-5
    Dgb0 = 4.0e-4
    Vm = 1.58e-29
    Qvc = 2.0
    #bulkindex = 1.0
    #surfindex = 1.0
    #gbindex = 1.0
    kb = 8.617343e-5
    JtoeV = 6.24150974e18
    c = c
    v = 'gr0 gr1   '
    bulkindex = 1.0
    surfindex = 1.0
    gbindex = 1.0
    length_scale = 1e-07
    time_scale = 0.001
  [../]
  [./constant_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = '  A       B     L   kappa_op  kappa_c'
    prop_values = '25.436 2.466 10.68  7.397     13.951    '
  [../]
[]

[VectorPostprocessors]
  [./grain_volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = grain_center
    execute_on = 'initial timestep_begin'
  [../]
[]

[UserObjects]
  [./grain_center]
    type = GrainTracker
    outputs = none
    compute_var_to_feature_map = true
    execute_on = 'initial timestep_begin'
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
  [./nonlinear_iterations]
    type = NumNonlinearIterations
  [../]
  [./linear_iterations]
    type = NumLinearIterations
  [../]
  [./elapsed_alive]
    type = PerformanceData
    event = 'ALIVE'
  [../]
  [./elapsed_active]
    type = PerformanceData
    event = 'ACTIVE'
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    coupled_groups = 'c,w c,gr0,gr1'
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
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
  end_time = 200
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
      lower_bound = 0.05
      upper_bound = 0.99
      variable = bnds
    [../]
  [../]
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
  csv = true
  gnuplot = true
  print_perf_log = true
  #interval = 10
  [./console]
    type = Console
    perf_log = true
  [../]
[]

[ICs]
  [./ic_gr1]
    type = SmoothCircleIC
    int_width = 5.0
    x1 = 95.0
    y1 = 50.0
    z1 = 50.0
    radius = 20.0
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
    3D_spheres = true
  [../]
  [./ic_gr0]
    type = SmoothCircleIC
    int_width = 5.0
    x1 = 50.0
    y1 = 50.0
    z1 = 50.0
    radius = 25.0
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
    3D_spheres = true
  [../]

  [./multip]
    x_positions = '50.0 95.0'
    y_positions = '50.0 50.0'
    z_positions = '50.0 50.0'
    int_width = 5.0
    radii = '25.0 20.0'
    3D_spheres = true
    outvalue = 0.001
    variable = c
    invalue = 0.999
    type = SpecifiedSmoothCircleIC
    block = 0
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
