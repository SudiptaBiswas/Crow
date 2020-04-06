[Mesh]
  type = GeneratedMesh
  xmax = 50
  ymax = 50
  zmax = 50
  nx = 20
  ny = 20
  nz = 20
  dim = 3
[]

[Modules]
  [./PhaseField]
    [./Conserved]
      [./c]
        free_energy = F
        kappa = kappa
        mobility = M
        solve_type = FORWARD_SPLIT
      [../]
    [../]
  [../]
[]

[ICs]
  [./c_IC]
    type = RandomIC
    variable = c
    max = 0.51
    min = 0.49
  [../]
[]

[Materials]
  [./constant_props]
    type = GenericConstantMaterial
    prop_names = 'kappa M'
    prop_values = '2 5'
  [../]
  [./F_mat]
    type = DerivativeParsedMaterial
    f_name = F
    args = c
    function = 'A*(c - ca)^2*(c - cb)^2'
    constant_names = 'A ca cb'
    constant_expressions = '5 0.1 0.9'
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
  solve_type = NEWTON

  scheme = bdf2

  petsc_options_iname = '-pc_type -sub_pc_type'
  petsc_options_value = 'asm lu'

  nl_max_its = 12
  l_max_its = 40
  l_tol = 1e-4
  nl_rel_tol = 1e-8
  end_time = 1e6

  dt = 0.1
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
