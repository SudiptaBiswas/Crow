[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 40
  ny = 40
  xmax = 40
  ymax = 20
[]

[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  block = '0'
[]

[Variables]
  [./T]
    initial_condition = 1200.0
  [../]
  [./elec]
  [../]
[]

[AuxVariables]
  [./c]
  [../]
  [./gr0]
  [../]
  [./gr1]
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
  #[./ic_c]
  #  int_width = 2.0
  #  x1 = 10.0
  #  y1 = 10.0
  #  radius = 7.4
  #  outvalue = 0.0
  #  variable = c
  #  invalue = 1.0
  #  type = SmoothCircleIC
  #[../]
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

[Kernels]
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
  [../]
  [./electric]
    type = HeatConduction
    variable = elec
    diffusion_coefficient = electrical_conductivity
  [../]
  [./electric_bc]
    type = ElectricBCKernel
    variable = elec
  [../]
[]

[BCs]
  #[./lefttemp]
  #  type = DirichletBC
  #  boundary = left
  #  variable = T
  #  value = 20
  #[../]
  #[./elec_left]
  #  type = DirichletBC
  #  variable = elec
  #  boundary = left
  #  value = 1
  #[../]
  #[./elec_right]
  #  type = DirichletBC
  #  variable = elec
  #  boundary = right
  #  value = 0
  #[../]
[]

[Functions]
  [./volumetric_heat]
     type = ParsedFunction
     value = -1.0
  [../]
  [./volumetric_heat1]
     type = ParsedFunction
     value = 1.0
  [../]
[]

[Materials]
  [./k]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity'
    prop_values = '0.95' #copper in cal/(cm sec C)
    block = 0
  [../]
  [./cp]
    type = GenericConstantMaterial
    prop_names = 'specific_heat'
    prop_values = '0.092' #copper in cal/(g C)
    block = 0
  [../]
  [./rho]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '8.92' #copper in g/(cm^3)
    block = 0
  [../]
  [./sigma]
    type = ElectricalConductivity
    temp = T
    ref_temp = 300
    ref_resistivity = 0.0168
    temp_coeff = 0.00386
    length_scale = 1e-02
    outputs = exodus
  [../]
  [./elec_bc]
    type = ElectricBCMat
    elec = elec
    c = c
    #bc_type = Neumann
    left_function = volumetric_heat
    right_function = volumetric_heat1
    top_function = volumetric_heat
    bottom_function = volumetric_heat1
    boundary_side = 'Left Right Top Bottom'
    outputs = exodus
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
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         101   preonly   lu      1'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-3
  l_max_its = 20
  nl_max_its = 20
  dt = 1
  end_time = 5
[]

[Outputs]
  #exodus = true
  print_perf_log = true
  print_linear_residuals = true
  [./exodus]
    type = Exodus
    elemental_as_nodal = true
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
