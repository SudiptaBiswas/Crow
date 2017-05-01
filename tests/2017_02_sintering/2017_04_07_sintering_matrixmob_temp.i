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
  [./T]
    initial_condition = 1200
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
  #[./heat]
  #  type = HeatConduction
  #  variable = T
  #  diffusion_coefficient = electrical_conductivity
  #  #block = 0
  #[../]
  [./heat_ie]
    type = HeatConductionTimeDerivative
    variable = T
    #block = 0
  [../]
  [./electric]
    type = MatDiffusion
    variable = T
    D_name = thermal_conductivity
    args = 'c'
  [../]
  [./bc]
    type = ElectricBCKernel
    variable = T
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
[]

[Functions]
  [./volumetric_heat]
     type = ParsedFunction
     value = 1.0
  [../]
  [./volumetric_heat1]
     type = ParsedFunction
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
  #[./CH_mat]
  #  type = PFDiffusionGrowth
  #  block = 0
  #  rho = c
  #  v = 'gr0 gr1'
  #  outputs = console
  #[../]
  [./constant_mat]
    type = GenericConstantMaterial

    prop_names = '  A         B       kappa_op    kappa_c   L '
    prop_values = '16.0   1.0          0.5         1.0      1.0 '
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
    length_scale = 1e-08
    time_scale = 1e-4
    bulkindex = 1.0
    surfindex = 1.0
    gbindex = 1.0
  [../]
  [./k]
    type = ParsedMaterial
    f_name = thermal_conductivity_phase1
    function = '1079.866' #copper in W/(cm sec K)
    #function = '0.95' #copper in W/(cm sec K)
  [../]
  [./cp]
    type = ParsedMaterial
    f_name = specific_heat_phase1
    #function = '0.143*6.24150974e18' #copper in ev/(g K)
    function = '830.186e15' #copper in ev/(g K)
  [../]
  [./rho]
    type = GenericConstantMaterial
    prop_names = 'density_phase1'
    #prop_values = '19.25e-21' #copper in g/(nm^3)
    prop_values = '19.3e-18' #copper in g/(nm^3)
  [../]
  [./elec_bc]
    type = ElectricBCMat
    elec = T
    c = c
    bc_type = Neumann
    left_function = volumetric_heat
    right_function = volumetric_heat1
    #top_function = volumetric_heat
    #bottom_function = volumetric_heat1
    boundary_side = 'Left Right'
    outputs = exodus
  [../]
  [./switching]
    type = SwitchingFunctionMaterial
    block = 0
    function_name = h
    eta = c
    h_order = SIMPLE
  [../]
  [./elec_cond]
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
  [./density]
    type = DerivativeTwoPhaseMaterial
    W = 0
    eta = c
    args = 'T'
    f_name = density
    fa_name = 1e-20
    fb_name = density_phase1
    g = 0.0
    #h = 0.8
    outputs = exodus
    derivative_order = 2
  [../]
  [./spcfc_ht]
    type = DerivativeTwoPhaseMaterial
    W = 0
    eta = c
    args = 'T'
    f_name = specific_heat
    fa_name = 1.0
    fb_name = specific_heat_phase1
    g = 0.0
    #h = 0.8
    outputs = exodus
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
  petsc_options_value = 'asm         31   preonly   lu      1'
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
