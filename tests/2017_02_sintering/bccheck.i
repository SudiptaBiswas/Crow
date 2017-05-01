[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 40
  ny = 40
  xmax = 40
  ymax = 20
[]

[Variables]
  #active = 'u'

  [./u]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  #active = 'diff'

  [./diff]
    type = Diffusion
    variable = u
  [../]
  [./u_dot]
    type = TimeDerivative
    variable = u
  [../]
[]

[BCs]
  #active = 'left right'

  #[./left]
  #  type = DirichletBC
  #  variable = u
  #  boundary = 1
  #  value = 0
  #[../]
  [./left]
    type = NeumannBC
    variable = u
    boundary = 1
    value = -1
  [../]
  [./right]
    type = NeumannBC
    variable = u
    boundary = 2
    value = 1
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         101   preonly   lu      1'
  petsc_options = '-ksp_converged_reason'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-4
  l_max_its = 20
  nl_max_its = 20
  dt = 0.1
  end_time = 5
[]

[Outputs]
  file_base = neumannbc_out
  exodus = true
[]
