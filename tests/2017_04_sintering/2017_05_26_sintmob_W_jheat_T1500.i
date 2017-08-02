[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  #en_ratio = 1
  block = '0 1 2'
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


[MeshModifiers]
  [./subdomain0]
    type = SubdomainBoundingBox
    bottom_left = '2.0 0.0 0.0'
    top_right = '33.0 20.0 0.0'
    block_id = 0
  [../]
  [./subdomain1]
    type = SubdomainBoundingBox
    bottom_left = '0.0 0.0 0.0'
    top_right = '2.0 20.0 0.0'
    block_id = 1
  [../]
  [./subdomain2]
    type = SubdomainBoundingBox
    bottom_left = '33.0 0.0 0.0'
    top_right = '40.0 20.0 0.0'
    block_id = 2
  [../]
  [./interface]
    type = SideSetsBetweenSubdomains
    depends_on = subdomain1
    master_block = '0'
    paired_block = '1'
    new_boundary = 'master0_interface'
  [../]
  [./interface_again]
    type = SideSetsBetweenSubdomains
    depends_on = subdomain1
    master_block = '0'
    paired_block = '2'
    new_boundary = 'master1_interface'
  [../]
[]

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
  [./HeatDiff]
    type = MatDiffusion
    variable = T
    D_name = thermal_conductivity
    args = 'c'
  [../]
  [./HeatTdot]
    type = HeatConductionTimeDerivative
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
  [./Elecdot]
    type = TimeDerivative
    variable = elec
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
  [./elec_left]
    type = DirichletBC
    variable = elec
    boundary = left
    value = 1.0
  [../]
  [./elec_left]
    type = DirichletBC
    variable = elec
    boundary = 'master0_interface master1_interface'
    value = 1.0
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
  [./constant_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = '  A         B  kappa_op    kappa_c  L'
    prop_values = '19.94   2.14   6.43       11.04    3.42'
    #prop_names = '  A    B  '
    #prop_values = '16.0 1.0 '
  [../]
  [./mob]
    type = SinteringMobility
    T = 1500.0
    int_width = 2
    GBmob0 = 3.2e-6
    Qv = 5.22
    Qvc = 2.3
    Qgb = 3.05
    Qs = 3.14
    Qgbm = 1.08
    Dgb0 = 1.41e-5
    Dsurf0 = 4.0e-4
    Dvap0 = 4.0e-7
    Dvol0 = 0.0054
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
  [./k]
    type = ParsedMaterial
    f_name = thermal_conductivity_phase1
    function = '173e-9' #copper in W/(cm sec K)
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
    length_scale = 1e-4
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
  [./therm_cond]
    type = DerivativeTwoPhaseMaterial
    W = 0
    eta = c
    args = 'T'
    f_name = thermal_conductivity
    fa_name = 1e-6
    fb_name = thermal_conductivity_phase1
    g = 0.0
    #h = 0.8
    outputs = exodus
    derivative_order = 2
  [../]
  [./dens]
    type = DerivativeTwoPhaseMaterial
    W = 0
    eta = c
    args = 'T'
    f_name = density
    fa_name = 1e-6
    fb_name = density_phase1
    g = 0.0
    #h = 0.8
    outputs = exodus
    derivative_order = 2
  [../]
  [./spcf]
    type = DerivativeTwoPhaseMaterial
    W = 0
    eta = c
    args = 'T'
    f_name = specific_heat
    fa_name = 1e-6
    fb_name = specific_heat_phase1
    g = 0.0
    #h = 0.8
    outputs = exodus
    derivative_order = 2
  [../]
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
    coupled_groups = 'c,w c,gr0,gr1 c,T T,elec'
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
