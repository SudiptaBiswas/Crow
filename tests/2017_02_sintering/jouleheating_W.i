[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 60
  ny = 60
  xmax = 20
  ymax = 20
[]

[Variables]
  [./T]
    #initial_condition = 300.0
    #scaling = 1e-9
  [../]
  #[./elec]
  #  initial_condition = 5.0
  #  #scaling = 1e8
  #[../]
[]

[ICs]
  #[./T]
  #  type = RandomIC
  #  variable = T
  #  min = 0.4
  #  max = 1
  #[../]
  #[./elec]
  #  type = RandomIC
  #  variable = elec
  #[../]
[]

[AuxVariables]
  #[./elec]
  #  initial_condition = 10.0
  #[../]
[../]

[Kernels]
  [./HeatDiff]
    type = MatDiffusion
    variable = T
    D_name = thermal_conductivity
  [../]
  [./HeatTdot]
    type = HeatConductionTimeDerivative
    variable = T
  [../]
  [./HeatSrc]
    type = HeatSource
    variable = T
    value = 1
  [../]
  #[./HeatSrc]
  #  type = JouleHeatingSource
  #  variable = T
  #  elec = elec
  #[../]
  #[./electric]
  #  type = MatDiffusion
  #  variable = elec
  #  args = 'T'
  #  D_name = electrical_conductivity
  #[../]
  #[./elec_dot]
  #  type = TimeDerivative
  #  variable = elec
  #[../]
[]

[BCs]
  #[./lefttemp]
  #  type = DirichletBC
  #  boundary = left
  #  variable = T
  #  value = 300
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

[Materials]
  [./k]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity'
    prop_values = '1.09' #copper in cal/(cm sec C)
    block = 0
  [../]
  [./cp]
    type = GenericConstantMaterial
    prop_names = 'specific_heat'
    prop_values = '1.32e10' #copper in cal/(g C)
    block = 0
  [../]
  [./rho]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1.2e-12' #copper in g/(cm^3)
    block = 0
  [../]
  #[./sigma]
  #  type = ElectricalConductivity
  #  temp = T
  #  ref_temp = 300
  #  ref_resistivity = 5.6e-8
  #  temp_coeff = 0.00386
  #  length_scale = 1e6
  #[../]
  [./coeff]
    type = ParsedMaterial
    material_property_names = ' thermal_conductivity specific_heat density'
    f_name = D
    function = thermal_conductivity/specific_heat/density
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
  #[./SMP]
  #  type = FDP
  #  full = true
  #[../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         101   preonly   ilu      1'
  ##petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount  '
  ##petsc_options_value = '       lu         NONZERO               1e-12        '
  #petsc_options = '-ksp_converged_reason -snes_converged_reason -snes-check-jacobian'
  #petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  #petsc_options_value = '201                hypre    boomeramg      8'
  #
  #
  line_search = 'none'
  #line_search = basic
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-3
  l_max_its = 20
  #nl_max_its = 20
  dt = 1
  end_time = 5
[]

[Outputs]
  exodus = true
  print_perf_log = true
[]

[Debug]
  show_var_residual_norms = true
[]
