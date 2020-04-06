[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  xmax = 60
  ymax = 60
  uniform_refine = 1
  elem_type = QUAD4
[]

[Variables]
  [./c]
    order = THIRD
    family = HERMITE
    [./InitialCondition]
      max = .1
      type = RandomIC
      min = -.1
    [../]
  [../]
[]

[Kernels]
  active = 'CHint c_dot CHbulk'
  [./c_dot]
    type = TimeDerivative
    variable = c
  [../]
  [./CHbulk]
    type = CHChemPotential
    variable = c
  [../]
  [./CHint]
    type = CHInterface
    variable = c
    mob_name = M
    kappa_name = kappa_c
    grad_mob_name = grad_M
  [../]
  [./test]
    type = CHMath
    variable = c
    mob_name = D
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]
  active = 'test'
  [./mat]
    type = PFDiffusion
    block = 0
    kappa = 2
    rho = c
  [../]
  [./test]
    type = PFMobility
    block = 0
    mob = 1
  [../]
[]

[Postprocessors]
  [./top]
    type = SideIntegralVariablePostprocessor
    variable = c
    boundary = top
  [../]
[]

[Executioner]
  # petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  # petsc_options_value = 'hypre boomeramg 101'
  type = Transient
  dt = 2.0
  l_max_its = 30
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-9
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  l_tol = 1e-4
  end_time = 80.0
  scheme = bdf2
[]

[Outputs]
  output_initial = true
  exodus = true
  print_linear_residuals = true
  print_perf_log = true
[]

