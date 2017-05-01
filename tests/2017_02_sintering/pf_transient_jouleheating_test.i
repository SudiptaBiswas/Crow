[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 40
  ny = 40
  xmax = 20
  ymax = 20
[]

[GlobalParams]
  var_name_base = gr
  op_num = 1.0
  block = '0'
[]

[Variables]
  [./T]
    initial_condition = 1200.0
    #scaling = 1e15
  [../]
  [./elec]
    #initial_condition = 1.0
  [../]
[]

[Kernels]
  [./HeatDiff]
    type = HeatConduction
    variable = T
  [../]
  [./HeatTdot]
    type = HeatConductionTimeDerivative
    variable = T
  [../]
  #[./heatsource]
  #  type = HeatSource
  #  #block = 0
  #  function = volumetric_heat
  #  variable = T
  #[../]
  [./HeatSrc]
    type = JouleHeatingSource
    variable = T
    elec = elec
  [../]
  [./electric]
    type = MatDiffusion
    variable = elec
    D_name = electrical_conductivity
    args = 'T c'
  [../]
  [./elec_dot]
    type = TimeDerivative
    variable = elec
  [../]
  #[./electric_bc]
  #  type = ElectricBCKernel
  #  variable = elec
  #[../]
[]

[AuxVariables]
  [./grade_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./grade_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./c]
  [../]
  [./gr0]
  [../]
  #[./gr1]
  #[../]
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
  [./ic_c]
    int_width = 2.0
    x1 = 10.0
    y1 = 10.0
    radius = 7.4
    outvalue = 0.0
    variable = c
    invalue = 1.0
    type = SmoothCircleIC
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
  #[./multip]
  #  type = SpecifiedSmoothCircleIC
  #  x_positions = '10.0 25.0'
  #  int_width = 2.0
  #  z_positions = '0 0'
  #  y_positions = '10.0 10.0 '
  #  radii = '7.4 7.4'
  #  3D_spheres = false
  #  outvalue = 0.001
  #  variable = c
  #  invalue = 0.999
  #[../]
  #[./ic_gr1]
  #  type = SmoothCircleIC
  #  int_width = 2.0
  #  x1 = 25.0
  #  y1 = 10.0
  #  radius = 7.4
  #  outvalue = 0.0
  #  variable = gr1
  #  invalue = 1.0
  #[../]
  #[./ic_gr0]
  #  type = SmoothCircleIC
  #  int_width = 2.0
  #  x1 = 10.0
  #  y1 = 10.0
  #  radius = 7.4
  #  outvalue = 0.0
  #  variable = gr0
  #  invalue = 1.0
  #[../]
[]

[Functions]
  [./volumetric_heat]
     type = ParsedFunction
     value = -10.0
  [../]
  [./volumetric_heat1]
     type = ParsedFunction
     value = 50.0
  [../]
[]

[BCs]
  #[./lefttemp]
  #  type = DirichletBC
  #  boundary = left
  #  variable = T
  #  value = 300
  #[../]
  [./elec_left]
    type = NeumannBC
    variable = elec
    boundary = left
    value = 50
  [../]
  [./elec_right]
    type = NeumannBC
    variable = elec
    boundary = right
    value = -50
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
  #[./k]
  #  type = GenericConstantMaterial
  #  prop_names = 'thermal_conductivity'
  #  prop_values = '0.95' #copper in cal/(cm sec C)
  #  block = 0
  #[../]
  #[./cp]
  #  type = GenericConstantMaterial
  #  prop_names = 'specific_heat'
  #  prop_values = '0.092' #copper in cal/(g C)
  #  block = 0
  #[../]
  #[./heatcond]
  #  type = HeatConductionMaterial
  #  block = 0
  #  thermal_conductivity = 0.8
  #  specific_heat = 0.01
  #[../]
  #[./density]
  #  type = Density
  #  block = 0
  #  density = 10.0
  #[../]
  [./constant_mat]
    type = GenericConstantMaterial
    prop_names = '  therm_cond_phase1   density_phase1  spcfc_ht_phase1'
    prop_values = '      0.8            10.0              0.01'
  [../]
  #[./rho]
  #  type = GenericConstantMaterial
  #  prop_names = 'density'
  #  prop_values = '8.92' #copper in g/(cm^3)
  #  block = 0
  #[../]
  [./sigma]
    type = ElectricalConductivity
    temp = T
    ref_temp = 300
    ref_resistivity = 0.0168
    temp_coeff = 0.00386
    length_scale = 1e-02
    base_name = phase1
  [../]
  [./elec_bc]
    type = ElectricBCMat
    elec = elec
    c = c
    bc_type = Neumann
    left_function = volumetric_heat1
    right_function = volumetric_heat
    #top_function = volumetric_heat1
    #bottom_function = volumetric_heat1
    boundary_side = 'Left Right'
    outputs = exodus
  [../]

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
    fa_name = 1e-6
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
    fa_name = 1e-6
    fb_name = 0.1
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
    fa_name = 1e-6
    fb_name = spcfc_ht_phase1
    g = 0.0
    #h = 0.8
    outputs = exodus
    derivative_order = 2
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -sub_pc_factor_shift_type'
  petsc_options_value = 'asm         31                 preonly         lu          1              NONZERO'
  #petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  #petsc_options_value = '201                hypre    boomeramg      8'

  #petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  #petsc_options_value = 'lu       superlu_dist'
  #petsc_options = '-ksp_converged_reason'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-4
  l_max_its = 20
  nl_max_its = 20
  dt = 1
  end_time = 500
[]

[Outputs]
  #exodus = true
  print_perf_log = true
  file_base = eflux_test
  [./exodus]
    type = Exodus
    elemental_as_nodal = true
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
