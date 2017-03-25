[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  #en_ratio = 1
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 80
  ny = 40
  nz = 0
  xmin = 0.0
  xmax = 400.0
  ymin = 0.0
  ymax = 200.0
  zmax = 0
  uniform_refine = 2
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
  #[./dF0_x]
  #  order = CONSTANT
  #  family = MONOMIAL
  #[../]
  #[./dF0_y]
  #  order = CONSTANT
  #  family = MONOMIAL
  #[../]
  #[./dF1_x]
  #  order = CONSTANT
  #  family = MONOMIAL
  #[../]
  #[./dF1_y]
  #  order = CONSTANT
  #  family = MONOMIAL
  #[../]
  #[./vt_x]
  #  order = CONSTANT
  #  family = MONOMIAL
  #[../]
  #[./vt_y]
  #  order = CONSTANT
  #  family = MONOMIAL
  #[../]
  #[./vr_x]
  #  order = CONSTANT
  #  family = MONOMIAL
  #[../]
  #[./vr_y]
  #  order = CONSTANT
  #  family = MONOMIAL
  #[../]
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
  #[./motion]
  #  type = MultiGrainRigidBodyMotion
  #  variable = w
  #  c = c
  #  v = 'gr0 gr1'
  #  grain_force = grain_force
  #  grain_tracker_object = grain_center
  #  grain_volumes = grain_volumes
  #  translation_constant = 10.0
  #  rotation_constant = 1.0
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
  #[./dF00]
  #  type = MaterialStdVectorRealGradientAux
  #  variable = dF0_x
  #  property = force_density
  #[../]
  #[./dF01]
  #  type = MaterialStdVectorRealGradientAux
  #  variable = dF0_y
  #  property = force_density
  #  component = 1
  #[../]
  #[./dF10]
  #  type = MaterialStdVectorRealGradientAux
  #  variable = dF1_x
  #  property = force_density
  #  index = 1
  #[../]
  #[./dF11]
  #  type = MaterialStdVectorRealGradientAux
  #  variable = dF1_y
  #  property = force_density
  #  index = 1
  #  component = 1
  #[../]
  #[./vt_x]
  #  type = GrainAdvectionAux
  #  component = x
  #  grain_tracker_object = grain_center
  #  grain_force = grain_force
  #  grain_volumes = grain_volumes
  #  variable = vt_x
  #  translation_constant = 10.0
  #  rotation_constant = 0.0
  #[../]
  #[./vt_y]
  #  type = GrainAdvectionAux
  #  component = y
  #  grain_tracker_object = grain_center
  #  grain_volumes = grain_volumes
  #  grain_force = grain_force
  #  variable = vt_y
  #  translation_constant = 10.0
  #  rotation_constant = 0.0
  #[../]
  #[./vr_x]
  #  type = GrainAdvectionAux
  #  component = x
  #  grain_tracker_object = grain_center
  #  grain_force = grain_force
  #  grain_volumes = grain_volumes
  #  variable = vr_x
  #  translation_constant = 0.0
  #  rotation_constant = 1.0
  #[../]
  #[./vr_y]
  #  type = GrainAdvectionAux
  #  component = y
  #  grain_tracker_object = grain_center
  #  grain_volumes = grain_volumes
  #  grain_force = grain_force
  #  variable = vr_y
  #  translation_constant = 0.0
  #  rotation_constant = 1.0
  #[../]
  #[./unique_grains]
  #  type = FeatureFloodCountAux
  #  variable = unique_grains
  #  flood_counter = grain_center
  #  field_display = UNIQUE_REGION
  #  execute_on = timestep_begin
  #[../]
  #[./var_indices]
  #  type = FeatureFloodCountAux
  #  variable = var_indices
  #  flood_counter = grain_center
  #  field_display = VARIABLE_COLORING
  #  execute_on = timestep_begin
  #[../]
  #[./centroids]
  #  type = FeatureFloodCountAux
  #  variable = centroids
  #  execute_on = timestep_begin
  #  field_display = CENTROID
  #  flood_counter = grain_center
  #[../]
[]

[Materials]
  [./free_energy]
    type = SinteringFreeEnergy
    block = 0
    c = c
    v = 'gr0 gr1'
    #A = A
    #B = B
    #f_name = S
    derivative_order = 2
    #outputs = console
  [../]
  #[./CH_mat]
  #  type = PFDiffusionGrowth
  #  block = 0
  #  rho = c
  #  v = 'gr0 gr1'
  #  outputs = console
  #[../]
  [./constant_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = '  A         B       kappa_op    kappa_c L'
    prop_values = '19.9728   2.1221   636.6340   870.6906 10.0'
    #prop_names = '  A    B  '
    #prop_values = '16.0 1.0 '
  [../]
  [./mob]
    type = SinteringMtrxMobility
    block = '0'
    T = 1200.0
    int_width = 20
    #GB_energy = 6.86
    #surface_energy = 9.33
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
    length_scale = 1e-09
    time_scale = 1e-4
    outputs = exodus
    bulkindex = 1.0
    surfindex = 1.0
    gbindex = 1.0
  [../]
  ## materials for rigid body motion / grain advection
  #[./force_density]
  #  type = ForceDensityMaterial
  #  block = 0
  #  c = c
  #  etas = 'gr0 gr1'
  #  cgb = 0.14
  #  k = 20
  #  ceq = 1.0
  #[../]
[]

#[VectorPostprocessors]
#  [./forces]
#    type = GrainForcesPostprocessor
#    grain_force = grain_force
#  [../]
#  [./grain_volumes]
#    type = FeatureVolumeVectorPostprocessor
#    flood_counter = grain_center
#    execute_on = 'initial timestep_begin'
#  [../]
#[]
#
#[UserObjects]
#  [./grain_center]
#    type = GrainTracker
#    outputs = none
#    compute_var_to_feature_map = true
#    execute_on = 'initial timestep_begin'
#  [../]
#  [./grain_force]
#    type = ComputeGrainForceAndTorque
#    execute_on = 'linear nonlinear'
#    grain_data = grain_center
#    force_density = force_density
#    c = c
#    etas = 'gr0 gr1'
#    compute_jacobians = false
#  [../]
#[]

[Postprocessors]
  #[./mat_D]
  #  type = ElementIntegralMaterialProperty
  #  mat_prop = M_c
  #[../]
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
  #[./nonlinear_iterations]
  #  type = NumNonlinearIterations
  #[../]
  #[./linear_iterations]
  #  type = NumLinearIterations
  #[../]
  #[./elapsed_alive]
  #  type = PerformanceData
  #  event = 'ALIVE'
  #[../]
  #[./elapsed_active]
  #  type = PerformanceData
  #  event = 'ACTIVE'
  #[../]
  #[./res_calls]
  #  type = PerformanceData
  #  column = n_calls
  #  event = compute_residual()
  #[../]
  #[./jac_calls]
  #  type = PerformanceData
  #  column = n_calls
  #  event = compute_jacobian()
  #[../]
  #[./jac_total_time]
  #  type = PerformanceData
  #  column = total_time
  #  event = compute_jacobian()
  #[../]
  #[./jac_average_time]
  #  type = PerformanceData
  #  column = average_time
  #  event = compute_jacobian()
  #[../]
  #[./jac_total_time_with_sub]
  #  type = PerformanceData
  #  column = total_time_with_sub
  #  event = compute_jacobian()
  #[../]
  #[./jac_average_time_with_sub]
  #  type = PerformanceData
  #  column = average_time_with_sub
  #  event = compute_jacobian()
  #[../]
  #[./jac_percent_of_active_time]
  #  type = PerformanceData
  #  column = percent_of_active_time
  #  event = compute_jacobian()
  #[../]
  #[./jac_percent_of_active_time_with_sub]
  #  type = PerformanceData
  #  column = percent_of_active_time_with_sub
  #  event = compute_jacobian()
  #[../]
  [./int_area]
    type = InterfaceAreaPostprocessor
    variable = c
  [../]
  #[./mass_conservation]
  #  type = ConservationCheck
  #  grain_force = grain_force
  #  grain_tracker_object = grain_center
  #  grain_volumes = grain_volumes
  #  translation_constant = 10.0
  #  rotation_constant = 1
  #  execute_on = TIMESTEP_END
  #  variable = c
  #[../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    #full = true
    off_diag_column = 'c w c   c   gr0 gr1 gr0 gr1'
    off_diag_row    = 'w c gr0 gr1 c   c  gr1  gr0'
  [../]
#[./FDP]
#  type = FDP
#  full = true
#  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  scheme = BDF2
  solve_type = NEWTON
  #petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  #petsc_options_value = 'asm         31   preonly   lu      1'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist'
  l_max_its = 20
  nl_max_its = 20
  #nl_abs_tol = 1e-10
  #nl_rel_tol = 1e-08
  l_tol = 1e-04
  end_time = 500
  #dt = 0.01
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    growth_factor = 1.2
  [../]
  #[./Adaptivity]
  #  refine_fraction = 0.7
  #  coarsen_fraction = 0.1
  #  max_h_level = 2
  #  initial_adaptivity = 1
  #[../]
[]

#[Adaptivity]
#  marker = bound_adapt
#  max_h_level = 4
#  [./Indicators]
#    [./error]
#      type = GradientJumpIndicator
#      variable = bnds
#    [../]
#  [../]
#  [./Markers]
#    [./bound_adapt]
#      type = ValueThresholdMarker
#      third_state = DO_NOTHING
#      coarsen = 1.0
#      refine = 0.99
#      variable = bnds
#      invert = true
#    [../]
#    [./errorfrac]
#      type = ErrorFractionMarker
#      coarsen = 0.1
#      indicator = error
#      refine = 0.7
#    [../]
#  [../]
#[]
#

[Outputs]
  #exodus = true
  print_linear_residuals = true
  csv = true
  gnuplot = true
  print_perf_log = true
  #interval = 10
  file_base = grad_check
  #[./console]
  #  type = Console
  #  perf_log = true
  #[../]
  [./exodus]
    type = Exodus
    elemental_as_nodal = true
  [../]
[]

[ICs]
  [./ic_gr1]
    int_width = 20.0
    x1 = 250.0
    y1 = 100.0
    radius = 74.0
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./multip]
    x_positions = '100.0 250.0'
    int_width = 20.0
    z_positions = '0 0'
    y_positions = '100.0 100.0 '
    radii = '74 74'
    3D_spheres = false
    outvalue = 0.001
    variable = c
    invalue = 0.999
    type = SpecifiedSmoothCircleIC
    block = 0
  [../]
  [./ic_gr0]
    int_width = 20.0
    x1 = 100.0
    y1 = 100.0
    radius = 74
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
    type = SmoothCircleIC
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
