[GlobalParams]
  var_name_base = gr
  op_num = 4.0
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  nz = 0
  xmin = 0.0
  xmax = 40.0
  ymin = 0.0
  ymax = 40.0
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
  [./vt_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vt_y]
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
[]

[Kernels]
  [./cres]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa_c
    w = w
    f_name = F
    args = 'gr0 gr1 gr2 gr3'
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
    grain_force = grain_force
    grain_tracker_object = grain_center
    grain_volumes = grain_volumes
    translation_constant = 1.0
    rotation_constant = 0.0
    anisotropic = false
  [../]
  [./motion]
    type = MultiGrainRigidBodyMotion
    variable = w
    c = c
    grain_force = grain_force
    grain_tracker_object = grain_center
    grain_volumes = grain_volumes
    translation_constant = 1.0
    rotation_constant = 0.0
  [../]
[]

[BCs]
  [./Periodic]
    [./All]
      auto_direction = 'x y'
      variable = 'c w gr0 gr1 gr2 gr3'
    [../]
  [../]
[]

[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    v = 'gr0 gr1 gr2 gr3'
  [../]
  [./Total_en]
    type = TotalFreeEnergy
    variable = total_en
    kappa_names = 'kappa_c kappa_op kappa_op kappa_op kappa_op'
    interfacial_vars = 'c  gr0 gr1 gr2 gr3'
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
  [./vt_x]
    type = GrainAdvectionAux
    component = x
    grain_tracker_object = grain_center
    grain_force = grain_force
    grain_volumes = grain_volumes
    variable = vt_x
    translation_constant = 1.0
    rotation_constant = 0.0
  [../]
  [./vt_y]
    type = GrainAdvectionAux
    component = y
    grain_tracker_object = grain_center
    grain_volumes = grain_volumes
    grain_force = grain_force
    variable = vt_y
    translation_constant = 1.0
    rotation_constant = 0.0
  [../]
  # [./vr_x]
  #   type = GrainAdvectionAux
  #   component = x
  #   grain_tracker_object = grain_center
  #   grain_force = grain_force
  #   grain_volumes = grain_volumes
  #   variable = vr_x
  #   translation_constant = 0.0
  #   rotation_constant = 1.0
  # [../]
  # [./vr_y]
  #   type = GrainAdvectionAux
  #   component = y
  #   grain_tracker_object = grain_center
  #   grain_volumes = grain_volumes
  #   grain_force = grain_force
  #   variable = vr_y
  #   translation_constant = 0.0
  #   rotation_constant = 1.0
  # [../]
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
[]

[Materials]
  [./free_energy]
    type = SinteringFreeEnergy
    block = 0
    c = c
    v = 'gr0 gr1 gr2 gr3'
    #A = A
    #B = B
    #f_name = S
    derivative_order = 2
    #outputs = console
  [../]
  [./CH_mat]
    type = PFDiffusionGrowth
    block = 0
    rho = c
    v = 'gr0 gr1 gr2 gr3'
    outputs = console
  [../]
  [./constant_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = '  A    B    kappa_op  kappa_c  L'
    prop_values = '16.0  1.0   1.0       10.0     10.0'
  [../]
  # [./force_density]
  #   type = ForceDensityMaterial
  #   block = 0
  #   c = c
  #   etas = 'gr0 gr1 gr2 gr3'
  #   cgb = 0.14
  #   k = 100
  #   ceq = 0.9816
  # [../]
[]

[VectorPostprocessors]
  [./forces]
    type = GrainForcesPostprocessor
    grain_force = grain_force
  [../]
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
  # [./grain_force]
  #   type = ComputeGrainForceAndTorque
  #   execute_on = 'timestep_begin linear nonlinear'
  #   grain_data = grain_center
  #   force_density = force_density
  #   c = c
  #   etas = 'gr0 gr1 gr2 gr3'
  #   compute_jacobians = false
  # [../]
  [./grain_force]
    type = ConstantGrainForceAndTorque
    execute_on = 'timestep_begin linear nonlinear'
    force = '0.5 -0.1 0.1 -0.5'
    torque = '0.0 0.0 0.0 0.0'
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
  [./grain_size_gr2]
    type = ElementIntegralVariablePostprocessor
    variable = gr2
  [../]
  [./grain_size_gr3]
    type = ElementIntegralVariablePostprocessor
    variable = gr3
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
    coupled_groups = 'c,w c,gr0,gr1,gr2,gr3'
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  scheme = BDF2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   ilu      1'
  #petsc_options = '-ksp_converged_reason -snes_converged_reason'
  l_max_its = 20
  nl_max_its = 20
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-08
  l_tol = 1e-04
  end_time = 50
  #dt = 0.01
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    growth_factor = 1.2
  [../]
[]

[Adaptivity]
  marker = err_frac
  max_h_level = 3
  initial_steps = 1
  initial_marker = bound_adapt
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
      upper_bound = 0.95
      variable = c
    [../]
    [./err_frac]
      type = ErrorFractionMarker
      refine = 0.8
      coarsen = 0.3
      indicator = error
    [../]
  [../]
[]

[Outputs]
  print_linear_residuals = true
  csv = true
  [./pgraph]
    type = PerfGraphOutput
    level = 2
  [../]
  [./exodus]
    type = Exodus
    elemental_as_nodal = true
  [../]
[]

[ICs]
  [./ic_gr1]
    type = SmoothCircleIC
    int_width = 2.0
    x1 = 30.0
    y1 = 12.0
    radius = 6.0
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
  [../]
  [./multip]
    type = SpecifiedSmoothCircleIC
    x_positions = '15.0 30.0 10.0 25.0'
    int_width = 2.0
    z_positions = '0 0 0 0'
    y_positions = '12.5 12.0 27.0 27.0 '
    radii = '8.0 6.0 6.0 9.0'
    3D_spheres = false
    outvalue = 0.001
    variable = c
    invalue = 0.999
    block = 0
  [../]
  [./ic_gr0]
    type = SmoothCircleIC
    int_width = 2.0
    x1 = 15.0
    y1 = 12.5
    radius = 8.0
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
  [../]
  [./ic_gr2]
    type = SmoothCircleIC
    int_width = 2.0
    x1 = 10.0
    y1 = 27.0
    radius = 6.0
    outvalue = 0.0
    variable = gr2
    invalue = 1.0
  [../]
  [./ic_gr3]
    type = SmoothCircleIC
    int_width = 2.0
    x1 = 25.0
    y1 = 27.0
    radius = 9.0
    outvalue = 0.0
    variable = gr3
    invalue = 1.0
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
