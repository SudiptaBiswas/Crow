[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 80
  ny = 40
  xmin = 2.5
  xmax = 32.5
  ymax = 20.0
[]

[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  block = '0'
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
    initial_condition = 1000.0
    #scaling = 1e15
  [../]
  [./elec]
    #initial_condition = 1.0
  [../]
[]

[Kernels]
  [./cres]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa_c
    w = w
    f_name = F
    args = 'gr0 gr1 T'
  [../]
  [./wres]
    type = SplitCHWResAniso
    variable = w
    mob_name = D
    args = 'T c gr0 gr1'
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
    type = HeatConduction
    variable = T
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
  [../]
  [./elec_dot]
    type = CoefTimeDerivative
    variable = elec
    #Coefficient = 0.01
  [../]
  #[./electric_bc]
  #  type = ElectricBCKernel
  #  variable = elec
  #[../]
[]

[AuxVariables]
  [./bnds]
  [../]
  [./total_en]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./grade_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./grade_y]
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
  [./grade_x]
    type = VariableGradientComponent
    variable = grade_x
    gradient_variable = elec
    component = x
  [../]
  [./grade_y]
    type = VariableGradientComponent
    variable = grade_y
    gradient_variable = elec
    component = y
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

[ICs]
  [./multip]
    type = SpecifiedSmoothCircleIC
    x_positions = '10.0 25.0'
    int_width = 2.0
    z_positions = '0 0'
    y_positions = '10.0 10.0 '
    radii = '7.4 7.4'
    3D_spheres = false
    outvalue = 0.001
    variable = c
    invalue = 0.999
  [../]
  [./ic_gr1]
    type = SmoothCircleIC
    int_width = 2.0
    x1 = 25.0
    y1 = 10.0
    radius = 7.4
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
  [../]
  [./ic_gr0]
    type = SmoothCircleIC
    int_width = 2.0
    x1 = 10.0
    y1 = 10.0
    radius = 7.4
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
  [../]
[]

[Functions]
  [./volumetric_heat]
     type = ParsedFunction
     value = 5.0
  [../]
  [./volumetric_heat1]
     type = ParsedFunction
     value = -5.0
  [../]
[]

[BCs]
  [./flux]
    type = CahnHilliardAnisoFluxBC
    variable = w
    boundary = 'top bottom left right'
    flux = '0 0 0'
    mob_name = D
    args = 'c'
  [../]
  [./elec_left]
    type = NeumannBC
    variable = elec
    boundary = left
    value = 2.0
  [../]
  [./elec_right]
    type = NeumannBC
    variable = elec
    boundary = right
    value = -1.0
  [../]
  #[./elec_right]
  #  type = CahnHilliardFluxBC
  #  variable = elec
  #  boundary = 'left'
  #  flux = '1.0 0 0'
  #  mob_name = electrical_conductivity
  #  args = 'T'
  #[../]
  #[./elec_top]
  #  type = CahnHilliardFluxBC
  #  variable = elec
  #  boundary = 'top'
  #  flux = '0 1.0 0'
  #  mob_name = electrical_conductivity
  #  args = 'T'
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
  [./mob]
    type = SinteringMtrxMobility
    T = T
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
  [./constant_mat]
    type = GenericConstantMaterial
    prop_names = '  phase1_electrical_conductivity therm_cond_phase1   density_phase1  spcfc_ht_phase1  A     B   kappa_op  kappa_c   L '
    prop_values = '     5.0                             10.0            10.0              0.01           16.0  1.0  1.0      10.0      1.0'
  [../]
  #[./sigma]
  #  type = ElectricalConductivity
  #  temp = T
  #  ref_temp = 1000
  #  ref_resistivity = 0.0054
  #  temp_coeff = 0.0048
  #  #length_scale = 1e-08
  #  base_name = phase1
  #[../]
  #[./elec_bc]
  #  type = ElectricBCMat
  #  elec = elec
  #  c = c
  #  bc_type = Neumann
  #  left_function = volumetric_heat
  #  right_function = volumetric_heat1
  #  #top_function = volumetric_heat
  #  #bottom_function = volumetric_heat1
  #  boundary_side = 'Left Right'
  #  outputs = exodus
  #[../]
  [./switching]
    type = DerivativeParsedMaterial
    block = 0
    f_name = h
    args = c
    function = 'c'
  [../]

  [./therm_cond]
    type = DerivativeTwoPhaseMaterial
    W = 0
    eta = c
    args = 'T'
    f_name = thermal_conductivity
    fa_name = 1e-16
    fb_name = therm_cond_phase1
    g = 0.0
    #h = 0.8
    outputs = exodus
    derivative_order = 2
  [../]

  [./elec_cond]
    type = DerivativeTwoPhaseMaterial
    W = 0
    eta = c
    args = 'T'
    f_name = electrical_conductivity
    fa_name = 1e-16
    fb_name = phase1_electrical_conductivity
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
  [./spcfc_ht]
    type = DerivativeTwoPhaseMaterial
    W = 0
    eta = c
    args = 'T'
    f_name = specific_heat
    fa_name = 1e-16
    fb_name = spcfc_ht_phase1
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
    system = 'NL'
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
    full = true
    coupled_groups = 'c,w c,gr0,gr1 c,T,elec'
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -sub_pc_factor_shift_type'
  petsc_options_value = 'asm         31                 preonly         lu          1              NONZERO'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-4
  l_max_its = 20
  nl_max_its = 20
  #dt = 1
  end_time = 500
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0
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
      lower_bound = 0.05
      upper_bound = 0.99
      variable = bnds
    [../]
  [../]
[]

[Outputs]
  print_perf_log = true
  csv = true
  gnuplot = true
  #file_base = flux_check
  [./exodus]
    type = Exodus
    elemental_as_nodal = true
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
