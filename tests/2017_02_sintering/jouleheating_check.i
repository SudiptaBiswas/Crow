[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  xmax = 20
  ymax = 20
[]

[Variables]
  #[./T]
  #  initial_condition =300.0
  #  #scaling = 1e15
  #[../]
  [./elec]
    #initial_condition = 1.0
  [../]
[]

[Kernels]
  #[./HeatDiff]
  #  type = HeatConduction
  #  variable = T
  #[../]
  #[./HeatTdot]
  #  type = HeatConductionTimeDerivative
  #  variable = T
  #[../]
  #[./heatsource]
  #  type = HeatSource
  #  #block = 0
  #  function = volumetric_heat
  #  variable = T
  #[../]
  #[./HeatSrc]
  #  type = JouleHeatingSource
  #  variable = T
  #  elec = elec
  #[../]
  [./electric]
    type = MatDiffusion
    variable = elec
    D_name = electrical_conductivity
    #args = 'T'
  [../]
[]

[AuxVariables]
  #[./elec]
  #  #initial_condition = 1.0
  #[../]
  [./grade_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./grade_y]
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
[]


[Functions]
  [./volumetric_heat]
     type = ParsedFunction
     value = 50.0
  [../]
[]

[ICs]
  #[./T]
  #  type = RandomIC
  #  variable = T
  #[../]
  #[./elec]
  #  type = RandomIC
  #  variable = elec
  #[../]
[]


[BCs]
  [./lefttemp]
    type = NeumannBC
    boundary = left
    variable = elec
    value = 0.1
  [../]
  #[./elec_left]
  #  type = DirichletBC
  #  variable = elec
  #  boundary = left
  #  value = 1.0
  #[../]
  #[./elec_right]
  #  type = DirichletBC
  #  variable = elec
  #  boundary = right
  #  value = 0
  #[../]
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
  [./k]
    type = GenericConstantMaterial
    prop_names = 'electrical_conductivity'
    prop_values = '0.95' #copper in cal/(cm sec C)
    block = 0
  [../]
  #[./cp]
  #  type = GenericConstantMaterial
  #  prop_names = 'specific_heat'
  #  prop_values = '0.092' #copper in cal/(g C)
  #  block = 0
  #[../]
  #[./heatcond]
  #  type = HeatConductionMaterial
  #  block = 0
  #  thermal_conductivity = 1.0
  #  specific_heat = 0.01
  #[../]
  #[./density]
  #  type = Density
  #  block = 0
  #  density = 10.0
  #[../]
  #[./rho]
  #  type = GenericConstantMaterial
  #  prop_names = 'density'
  #  prop_values = '8.92' #copper in g/(cm^3)
  #  block = 0
  #[../]
  #[./sigma]
  #  type = ElectricalConductivity
  #  temp = 800
  #  ref_temp = 300
  #  ref_resistivity = 0.0168
  #  temp_coeff = 0.00386
  #  length_scale = 1e-02
  #[../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Steady
  #scheme = bdf2
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
  #dt = 10
  #end_time = 50
[]

[Outputs]
  exodus = true
  print_perf_log = true
[]

[Debug]
  show_var_residual_norms = true
[]
