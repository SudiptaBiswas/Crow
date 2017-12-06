[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  int_width = 20.0
  grain_num = 2.0
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 40
  ny = 25
  nz = 0
  xmin = 0.0
  xmax = 400.0
  ymin = 0.0
  ymax = 250.0
  zmax = 0
  #uniform_refine = 2
  elem_type = QUAD4
[]

[Variables]
  [./c]
    #scaling = 10
  [../]
  [./w]
    #scaling = 10
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
  [./vt_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vt_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vr_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vr_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dF0_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dF0_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dF1_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dF1_y]
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
  [./aniso_gb_energy] # Stores GB energy in J/m^2 where energy is zero within grains
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./euler_angle]
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
    mob_name = M
  [../]
  [./time]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./PolycrystalSinteringKernel]
    c = c
    anisotropic = true
    length_scale = 1e-08
    gbenergymap = AnisoEnergy
    consider_rigidbodymotion = true
    grain_force = grain_force
    grain_tracker_object = grain_center
    grain_volumes = grain_volumes
    translation_constant = 100.0
    rotation_constant = 2.0
  [../]
  [./motion]
    type = MultiGrainRigidBodyMotion
    variable = w
    c = c
    grain_force = grain_force
    grain_tracker_object = grain_center
    grain_volumes = grain_volumes
    translation_constant = 100.0
    rotation_constant = 2.0
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
  [./vt_x]
    type = GrainAdvectionAux
    component = x
    grain_tracker_object = grain_center
    grain_force = grain_force
    grain_volumes = grain_volumes
    variable = vt_x
    translation_constant = 100.0
    rotation_constant = 0.0
  [../]
  [./vt_y]
    type = GrainAdvectionAux
    component = y
    grain_tracker_object = grain_center
    grain_volumes = grain_volumes
    grain_force = grain_force
    variable = vt_y
    translation_constant = 100.0
    rotation_constant = 0.0
  [../]
  [./vr_x]
    type = GrainAdvectionAux
    component = x
    grain_tracker_object = grain_center
    grain_force = grain_force
    grain_volumes = grain_volumes
    variable = vr_x
    translation_constant = 0.0
    rotation_constant = 2.0
  [../]
  [./vr_y]
    type = GrainAdvectionAux
    component = y
    grain_tracker_object = grain_center
    grain_volumes = grain_volumes
    grain_force = grain_force
    variable = vr_y
    translation_constant = 0.0
    rotation_constant = 2.0
  [../]
  [./dF00]
    type = MaterialStdVectorRealGradientAux
    variable = dF0_x
    property = force_density
  [../]
  [./dF01]
    type = MaterialStdVectorRealGradientAux
    variable = dF0_y
    property = force_density
    component = 1
  [../]
  [./dF10]
    type = MaterialStdVectorRealGradientAux
    variable = dF1_x
    property = force_density
    index = 1
  [../]
  [./dF11]
    type = MaterialStdVectorRealGradientAux
    variable = dF1_y
    property = force_density
    index = 1
    component = 1
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
  [./aniso_gb_energy_aux]
    type = AnisoEnergyViewAux # Used for visualizing GB energy (units: J/m^2). Energies are sets to zero within grains.
    variable = aniso_gb_energy
    gb_energy_map = AnisoEnergy
    grain_tracker_object = grain_center
  [../]
  [./angle]
    type = OutputEulerAngles
    variable = euler_angle
    euler_angle_provider = euler_angle
    grain_tracker = grain_center
    output_euler_angle = phi1
    execute_on = timestep_begin
  [../]
[]

[BCs]
  [./flux]
    type = CahnHilliardFluxBC
    variable = w
    boundary = 'top bottom left right'
    flux = '0 0 0'
    mob_name = M
    args = 'c gr0 gr1'
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
  #  prop_names = '  A         B  kappa_op    kappa_c  L'
  #  prop_values = '19.94   2.14   6.43       11.04    3.42'
  #  #prop_names = '  A    B  '
  #  #prop_values = '16.0 1.0 '
  #[../]
  [./coeff]
    type = SinteringCoefficientsAniso
    block = 0
    T = 800.0
    GBmob0 = 2.5e-6
    Qgbm = 0.23
    surface_energy = 1.03e19
    #GB_energy = 4.42e18
    length_scale = 1e-08
    time_scale = 0.1
    energy_scale = 100.0
    energy_unit = eV
    gbenergymap = AnisoEnergy
    mobility_anisotropy = true
    inclination_anisotropy = true
    outputs = exodus
  [../]
  [./mob]
    type = SinteringMobility
    T = 800.0
    Qv = 2.19
    Qvc = 2.19
    Qgb = 0.75
    Qs = 0.9
    Dgb0 = 1.95e-8
    Dsurf0 = 2.6e-5
    Dvap0 = 7.8e-5
    Dvol0 = 7.8e-5
    c = c
    v = 'gr0 gr1'
    Vm = 1.182e-29
    length_scale = 1e-08
    time_scale = 0.1
    bulkindex = 1.0
    surfindex = 1.0
    gbindex = 1.0
    #prefactor = 0.1
    outputs = exodus
  [../]
  [./force_density]
    type = ForceDensityMaterial
    block = 0
    c = c
    etas = 'gr0 gr1'
    cgb = 0.05
    k = 2.0
    ceq = 1.0
    outputs = exodus
  [../]
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
    #threshold = 0.2
    #connecting_threshold = 0.08
    compute_var_to_feature_map = true
    execute_on = 'initial timestep_begin'
  [../]
  [./grain_force]
    type = ComputeGrainForceAndTorque
    execute_on = 'linear nonlinear'
    grain_data = grain_center
    force_density = force_density
    c = c
    etas = 'gr0 gr1'
    compute_jacobians = false
  [../]
  [./euler_angle]
    type = EulerAngleFileReader
    file_name = angle2.tex
  [../]
  [./AnisoEnergy]
    type = AnisoGBEnergyUserObject
    euler_angle_provider = euler_angle
    grain_tracker = grain_center
    execute_on = 'nonlinear linear'
    gb_energy_isotropic = 0.708
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
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -sub_pc_factor_shift_type'
  petsc_options_value = 'asm         31   preonly   lu      1 nonzero'
  #petsc_options = '-snes_converged_reason'
  l_max_its = 20
  nl_max_its = 20
  nl_abs_tol = 1e-08
  nl_rel_tol = 1e-06
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
      lower_bound = 0.005
      upper_bound = 0.935
      variable = bnds
    [../]
  [../]
[]

[Outputs]
  print_linear_residuals = true
  csv = true
  gnuplot = true
  print_perf_log = true
  file_base = 2017_09_07_2p_Cu_T800_unequal_aniso
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
    int_width = 20.0
    x1 = 250.0
    y1 = 120.0
    radius = 80.0
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./multip]
    x_positions = '110.0 250.0'
    int_width = 20.0
    z_positions = '0 0'
    y_positions = '150.0 120.0'
    radii = '60.0 80.0'
    3D_spheres = false
    outvalue = 0.001
    variable = c
    invalue = 0.999
    type = SpecifiedSmoothCircleIC
    block = 0
  [../]
  [./ic_gr0]
    int_width = 20.0
    x1 = 110.0
    y1 = 150.0
    radius = 60.0
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
    type = SmoothCircleIC
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
