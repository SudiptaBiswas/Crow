[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  block = '0'
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 80
  ny = 40
  nz = 0
  xmin = 2.0
  xmax = 32.8
  ymin = 0.0
  ymax = 20.0
  zmax = 0
  #uniform_refine = 2
  elem_type = QUAD4
[]
#
#[MeshModifiers]
#  [./subdomain1]
#    type = SubdomainBoundingBox
#    bottom_left = '0 0 0'
#    top_right = '20 200 0'
#    block_id = 1
#  [../]
#  [./subdomain2]
#    type = SubdomainBoundingBox
#    bottom_left = '330 0 0'
#    top_right = '350 200 0'
#    block_id = 2
#  [../]
#[]

[Variables]
  [./c]
    #scaling = 10
  [../]
  [./w]
  [../]
  [./PolycrystalVariables]
  [../]
  [./T]
    initial_condition = 800.0
    #scaling = 1e8
  [../]
  [./elec]
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
  [./current_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./current_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  #[./elec]
  #[../]
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
  [../]
  [./HeatDiff]
    type = MatDiffusion
    variable = T
    D_name = electrical_conductivity
    args = 'c'
  [../]
  [./HeatTdot]
    type = TimeDerivative
    variable = T
  [../]
  [./HeatSrc]
    type = JouleHeatingSource
    variable = T
    elec = elec
    args = 'c'
  [../]
  [./electric]
    type = MatDiffusion
    variable = elec
    D_name = electrical_conductivity
    args = 'T c'
    block = 0
  [../]
  #[./Elecdot]
  #  type = TimeDerivative
  #  variable = elec
  #[../]
  #[./electric_bc]
  #  type = ElectricBCKernel
  #  variable = elec
  #[../]
  #[./elec_1]
  #  type = BodyForce
  #  value = 0.1
  #  function = 'x'
  #  variable = elec
  #  block = '1'
  #[../]
  #[./elec_2]
  #  type = BodyForce
  #  value = 0.01
  #  function = '350-x'
  #  variable = elec
  #  block = '2'
  #[../]
[]

[BCs]
  #[./flux_left]
  #  type = NeumannBC
  #  variable = T
  #  boundary = left
  #  value = 1e-11
  #[../]
  #[./flux_right]
  #  type = NeumannBC
  #  variable = T
  #  boundary = right
  #  value = 1e-11
  #[../]
  #[./elec_left]
  #  type = NeumannBC
  #  variable = elec
  #  boundary = left
  #  value = -1.0
  #[../]
  #[./elec_left]
  #  type = CahnHilliardFluxBC
  #  variable = elec
  #  boundary = left
  #  flux = '-1.0 0.0 0.0'
  #  args = 'c T'
  #  mob_name = electrical_conductivity
  #  #value = -1.0
  #[../]
  [./elec_left]
    type = DirichletBC
    variable = elec
    boundary = left
    value = 0.2
  [../]
[]

[Functions]
  [./volumetric_heat]
     type = ParsedFunction
     value = -1.0
  [../]
  [./volumetric_heat1]
     type = ParsedFunction
     value = 5.0
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
  [./current_x]
    type = VariableGradientComponent
    variable = current_x
    gradient_variable = elec
    component = x
  [../]
  [./current_y]
    type = VariableGradientComponent
    variable = current_y
    gradient_variable = elec
    component = y
  [../]
  #[./elec]
  #  type = MaterialRealAux
  #  variable = elec
  #  property = h
  #  offset = 1e-6
  #  factor = 1
  #[../]
[]

[Materials]
  [./free_energy]
    type = SinteringFreeEnergy
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
  #
  #  rho = c
  #  v = 'gr0 gr1'
  #  outputs = console
  #[../]
  [./constant_mat]
    type = GenericConstantMaterial

    prop_names = '  A      B  kappa_op kappa_c L'
    prop_values = '16.0   1.0  1.0     1.0    1.0'
    #prop_names = '  A    B  '
    #prop_values = '16.0 1.0 '
  [../]
  [./mob]
    type = SinteringMtrxMobility
    T = 1200.0
    int_width = 2
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
    bulkindex = 1.0
    surfindex = 1.0
    gbindex = 1.0
  [../]
  ## materials for rigid body motion / grain advection
  #[./force_density]
  #  type = ForceDensityMaterial
  #
  #  c = c
  #  etas = 'gr0 gr1'
  #  cgb = 0.14
  #  k = 20
  #  ceq = 1.0
  #[../]
  [./k]
    type = ParsedMaterial
    f_name = thermal_conductivity_phase1
    function = '173e-3' #copper in W/(cm sec K)
    #function = '0.95' #copper in W/(cm sec K)

  [../]
  [./cp]
    type = ParsedMaterial
    f_name = specific_heat_phase1
    #function = '0.143*6.24150974e18' #copper in ev/(g K)
    function = '0.092' #copper in ev/(g K)

  [../]
  [./rho]
    type = GenericConstantMaterial
    prop_names = 'density_phase1'
    #prop_values = '19.25e-21' #copper in g/(nm^3)
    prop_values = '8.96' #copper in g/(nm^3)

  [../]
  #[./sigma]
  #  type = ElectricalConductivity
  #  temp = T
  #  base_name = phase1
  #  ref_temp = 300
  #  ref_resistivity = 0.56
  #  temp_coeff = 0.0045
  #  length_scale = 1
  #[../]
  [./sigma]
    type = ElectricalConductivity
    temp = T
    ref_temp = 300
    ref_resistivity = 1.68e-8
    temp_coeff = 0.0045
    #length_scale = 1e-4
    base_name = phase1
  [../]
  #[./weight]
  #  type = SwitchingFunctionMaterial
  #  eta = c
  #  function_name = h
  #  h_order = SIMPLE
  #[../]
  [./weight]
    type = DerivativeParsedMaterial
    args = 'c'
    f_name = h
    function = 'c+1e-3'
  [../]
  #[./opt]
  #  type = ParsedMaterial
  #  args = 'c'
  #  f_name = fn
  #  function = 'c+1e-6'
  #[../]
  [./elec_cond]
    type = DerivativeTwoPhaseMaterial
    W = 0
    eta = c
    args = 'T'
    f_name = electrical_conductivity
    fa_name = 1e-6
    fb_name = phase1_electrical_conductivity
    g = 0.0
    #h = 0.8
    outputs = exodus
    derivative_order = 2
  [../]
  #[./therm_cond]
  #  type = DerivativeTwoPhaseMaterial
  #  W = 0
  #  eta = c
  #  args = 'T'
  #  f_name = thermal_conductivity
  #  fa_name = 1e-6
  #  fb_name = thermal_conductivity_phase1
  #  g = 0.0
  #  #h = 0.8
  #  outputs = exodus
  #  derivative_order = 2
  #[../]
  #[./dens]
  #  type = DerivativeTwoPhaseMaterial
  #  W = 0
  #  eta = c
  #  args = 'T'
  #  f_name = density
  #  fa_name = 1e-6
  #  fb_name = density_phase1
  #  g = 0.0
  #  #h = 0.8
  #  outputs = exodus
  #  derivative_order = 2
  #[../]
  #[./spcf]
  #  type = DerivativeTwoPhaseMaterial
  #  W = 0
  #  eta = c
  #  args = 'T'
  #  f_name = specific_heat
  #  fa_name = 1e-6
  #  fb_name = specific_heat_phase1
  #  g = 0.0
  #  #h = 0.8
  #  outputs = exodus
  #  derivative_order = 2
  #[../]
  #[./elec_bc]
  #  type = ElectricBCMat
  #  elec = elec
  #  c = c
  #  bc_type = Dirichlet
  #  left_function = volumetric_heat1
  #  right_function = volumetric_heat
  #  #top_function = volumetric_heat1
  #  #bottom_function = volumetric_heat1
  #  boundary_side = 'Left Right'
  #  outputs = exodus
  #[../]
  [./grad_elc]
    type = VariableGradientMaterial
    prop = grad_elc
    variable = elec
  [../]
  [./current]
    type = DerivativeParsedMaterial
    material_property_names = 'electrical_conductivity grad_elc'
    f_name = current_prop
    function = 'electrical_conductivity*grad_elc'
    outputs = exodus
  [../]
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
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
    coupled_groups = 'c,w c,gr0,gr1 c,T T,elec'
    #off_diag_column = 'elec'
    #off_diag_row    = 'c'
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
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -sub_pc_factor_shift_type '
  petsc_options_value = 'asm         31   preonly   lu      1 nonzero'
  #petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap '
  #petsc_options_value = 'asm         31   preonly   lu      1'
  petsc_options = '-snes_converged_reason'
  #petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  #petsc_options_value = 'lu       superlu_dist'
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
#  marker = errorfrac
#  max_h_level = 2
#  [./Indicators]
#    [./error]
#      type = GradientJumpIndicator
#      variable = bnds
#    [../]
#  [../]
#  [./Markers]
#    #[./bound_adapt]
#    #  type = ValueThresholdMarker
#    #  third_state = DO_NOTHING
#    #  coarsen = 1.0
#    #  refine = 0.99
#    #  variable = bnds
#    #  invert = true
#    #[../]
#    [./errorfrac]
#      type = ErrorFractionMarker
#      coarsen = 0.1
#      indicator = error
#      refine = 0.7
#    [../]
#  [../]
#[]


[Outputs]
  #exodus = true
  print_linear_residuals = true
  csv = true
  gnuplot = true
  print_perf_log = true
  #interval = 10
  #file_base = 2017_05_03_2p_sint_elect
  [./exodus]
    type = Exodus
    elemental_as_nodal = true
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
  #[./elec_ic]
  #  type = RandomIC
  #  variable = elec
  #[../]
  #[./temp]
  #  type = RandomIC
  #  variable = T
  #[../]
[]

[Debug]
  show_var_residual_norms = true
[]
