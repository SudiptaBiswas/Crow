[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  block = 0
  #displacements = 'disp_x disp_y disp_z'
  #use_displaced_mesh = true
  #outputs = exodus
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 50
  ny = 30
  nz = 30
  xmax = 100.0
  ymax = 60.0
  zmax = 60.0
  uniform_refine = 1
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
[]

[Kernels]
  [./cres]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa_c
    w = w
    f_name = F
    args = 'gr0  gr1'
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
    consider_rigidbodymotion = false
    anisotropic = false
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
  #  v = 'gr0 gr1   '
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
    v = 'gr0 gr1 '
  [../]
  [./Total_en]
    type = TotalFreeEnergy
    variable = total_en
    kappa_names = 'kappa_c kappa_op kappa_op'
    interfacial_vars = 'c  gr0 gr1'
  [../]
[]

[BCs]
  [./flux]
    type = CahnHilliardFluxBC
    variable = w
    boundary = 'top bottom left right front back'
    flux = '0 0 0'
    mob_name = M
    args = 'c'
  [../]
[]

[Materials]
  [./free_energy]
    type = SinteringFreeEnergy
    block = 0
    c = c
    v = 'gr0 gr1'
    #f_name = S
    derivative_order = 2
    output_properties = 'S'
    outputs = exodus
  [../]
  [./mob]
    type = SinteringMobility
    T = 673.0
    int_width = 2
    Qv = 1.97
    #Qvc = 2.3
    Qgb = 2.4
    Qs = 2.4
    #Qgbm = 1.08
    Dgb0 = 10
    Dsurf0 = 100
    #Dvap0 = 4.0e-7
    Dvol0 = 0.67e-4
    c = c
    v = 'gr0 gr1'
    Vm = 1.71e-29
    length_scale = 1e-09
    time_scale = 0.1
    bulkindex = 1.0
    surfindex = 1.0
    gbindex = 1.0
    outputs = exodus
  [../]
  [./constant_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = '  A       B     L   kappa_op  kappa_c'
    prop_values = '25.436 2.466 10.68  7.397     13.951 '
  [../]
[]

[Postprocessors]
  [./mat_D]
    type = ElementIntegralMaterialProperty
    mat_prop = D
  [../]
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
  [./gb0_area]
    type = GrainBoundaryArea
    v = gr0
  [../]
  [./gb1_area]
    type = GrainBoundaryArea
    v = gr1
  [../]
  [./c_int_area]
    type = GrainBoundaryArea
    v = c
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
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-8
  nl_abs_tol = 1e-10
  end_time = 10000
  #dt = 0.01
  #[./Adaptivity]
  #  refine_fraction = 0.7
  #  coarsen_fraction = 0.1
  #  max_h_level = 2
  #  initial_adaptivity = 1
  #[../]
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    growth_factor = 1.5
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
      upper_bound = 0.95
      variable = bnds
    [../]
  [../]
[]

[Outputs]
  print_linear_residuals = true
  print_perf_log = true
  gnuplot = true
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
    x1 = 30.0
    y1 = 30.0
    z1 = 30.0
    radius = 20.0
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
    3D_spheres = true
    type = SmoothCircleIC
  [../]
  [./multip]
    x_positions = '30.0 72.0'
    int_width = 2.0
    z_positions = '30.0 30.0'
    y_positions = '30.0 30.0 '
    radii = '20.0 20.0'
    3D_spheres = true
    outvalue = 0.001
    variable = c
    invalue = 0.999
    type = SpecifiedSmoothCircleIC
    block = 0
  [../]
  [./ic_gr0]
    int_width = 2.0
    x1 = 72.0
    y1 = 30.0
    z1 = 30.0
    radius = 20.0
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
    3D_spheres = true
    type = SmoothCircleIC
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
