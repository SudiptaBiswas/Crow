[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  grain_num = 2.0
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
  [./unique_grains]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./var_indices]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./aniso_gb_energy] # Stores GB energy in J/m^2 where energy is zero within grains
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
    anisotropic = true
    length_scale = 1e-6
    int_width = 2
    gbenergymap = AnisoEnergy
    #grain_force = grain_force
    #grain_tracker_object = grain_center
    #grain_volumes = grain_volumes
    #translation_constant = 10.0
    #rotation_constant = 1.0
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
  [./unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    execute_on = timestep_end
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
  [../]
  [./var_indices]
    type = FeatureFloodCountAux
    variable = var_indices
    execute_on = timestep_end
    flood_counter = grain_tracker
    field_display = VARIABLE_COLORING
  [../]
  [./aniso_gb_energy_aux]
    type = AnisoEnergyViewAux # Used for visualizing GB energy (units: J/m^2). Energies are sets to zero within grains.
    variable = aniso_gb_energy
    gb_energy_map = AnisoEnergy
    grain_tracker_object = grain_tracker
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
  #[./constant_mat]
  #  type = GenericConstantMaterial
  #  block = 0
  #  prop_names = '  A         B  kappa_c'
  #  prop_values = '19.94   2.14  11.04 '
    #prop_names = '  A    B  '
    #prop_values = '16.0 1.0 '
  #[../]
  [./coeff]
    type = SinteringCoefficientsAniso
    block = 0
    T = 2000.0
    int_width = 2
    GBmob0 = 3.2e-7
    Qgbm = 2.6
    surface_energy = 9.33
#  GB_energy = 4.29e-21
    length_scale = 1e-08
    time_scale = 1e-04
    energy_scale = 1e-03
    energy_unit = Joule
    gbenergymap = AnisoEnergy
    outputs = exodus
  [../]
  #[./Aniso_L]
  #  type = GBEvolutionAniso # Quantitative material properties for copper grain growth.  Dimensions are nm and ns
  #  block = 0 # Block ID (only one block in this problem)
  #  GBmob0 = 3.2e-7 #Mobility prefactor for Cu from Schonfelder1997
  #  Q = 2.08 #Activation energy for grain growth from Schonfelder 1997
  #  T = 2000 # K   #Constant temperature of the simulation (for mobility calculation)
  #  wGB = 2 # nm      #Width of the diffuse GB
  #  gbenergymap = AnisoEnergy
  #  outputs = exodus
  #  length_scale = 1e-08
  #  time_scale = 1e-04
  #[../]
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
[]

[UserObjects]
  [./grain_tracker]
    type = GrainTracker
    threshold = 0.2
    use_single_map = false
    enable_var_coloring = true
    condense_map_info = true
    connecting_threshold = 0.08
    flood_entity_type = elemental
    compute_var_to_feature_map = true
    execute_on = 'initial timestep_begin'
    tracking_step = 0
  [../]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = test.tex
  [../]

  # Recalculates the free energy densities at the grain boundaries as function
  # of the grain orientations and grain boundary plane
  [./AnisoEnergy]
    type = AnisoGBEnergyUserObject
    euler_angle_provider = euler_angle_file
    grain_tracker = grain_tracker
    execute_on = 'nonlinear linear'
    gb_energy_isotropic = 9.33
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
  #[./run_time]
  #  type = RunTime
  #  time_type = active
  #[../]
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
    coupled_groups = 'c,w c,gr0,gr1'
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  scheme = BDF2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   ilu      1'
  l_max_its = 20
  nl_max_its = 20
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-08
  l_tol = 1e-04
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
      lower_bound = 0.01
      upper_bound = 0.95
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

[Debug]
  show_var_residual_norms = true
[]
