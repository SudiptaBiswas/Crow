[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  xmax = 5
  ymax = 5
[]

[Variables]
  [./T]
    initial_condition = 20.0
  [../]
  [./elec]
  [../]
[]

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
    type = ElectricFieldKernel
    variable = T
    elec = elec
  [../]
  [./electric]
    type = MatDiffusion
    variable = elec
    D_name = electrical_conductivity
    args = 'T'
  [../]
[]

[BCs]
  [./lefttemp]
    type = PresetBC
    boundary = 1
    variable = T
    value = 25
  [../]
  [./elec_left]
    type = DirichletBC
    variable = elec
    boundary = left
    value = 2
  [../]
  [./elec_right]
    type = DirichletBC
    variable = elec
    boundary = right
    value = 0
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
    type = ResistivityMaterial
    temp = T
    ref_temp = 20
    ref_resistivity = 6.5e-06
    length_scale = 1e-02
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
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         101   preonly   ilu      1'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-4
  dt = 1
  end_time = 10
[]

[Outputs]
  exodus = true
  print_perf_log = true
[]
