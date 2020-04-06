[Mesh]
  type = GeneratedMesh
  xmin = -375
  ymin = -375
  xmax = 375
  ymax = 375
  nx = 23
  ny = 23
  dim = 2
[]

[Modules]
  [./PhaseField]
    [./Conserved]
      [./eta]
        free_energy = f_total
        kappa = kappa
        mobility = M
        solve_type = FORWARD_SPLIT
      [../]
    [../]
  [../]
[]

[ICs]
  [./eta_IC]
    type = SmoothSuperellipsoidIC
    variable = eta
    a = 83.33
    b = 67.5
    c = 75
    n = 2
    int_width = 15
    invalue = 1
    outvalue = 0.01
    x1 = 0
    y1 = 0
    z1 = 0
  [../]
[]

[AuxVariables]
  [./fdens_total]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./fint]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./fdens_total]
    type = TotalFreeEnergy
    interfacial_vars = eta
    kappa_names = kappa
    variable = fdens_total
    f_name = f_total
    execute_on = TIMESTEP_END
  [../]
  [./fint]
    type = TotalFreeEnergy
    interfacial_vars = eta
    kappa_names = kappa
    variable = fint
    f_name = zero
    execute_on = TIMESTEP_END
  [../]
[]

[Materials]
  [./constant_parameters]
    type = GenericConstantMaterial
    prop_names = 'kappa M w zero'
    prop_values =  '0.58 5 0.051 0'
  [../]
  [./free_energy]

    type = DerivativeParsedMaterial
    f_name = f_bulk
    args = eta
    material_property_names = w
    constant_names = 'a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10'
    constant_expressions = '0 0 8.072789087 -81.24549382 408.0297321 -1244.129167 2444.046270 -3120.635139 2506.663551 -1151.003178 230.2006355'
    function = 'w*(a0 + a1*eta + a2*eta^2 + a3*eta^3 + a4*eta^4 + a5*eta^5 + a6*eta^6 + a7*eta^7 + a8*eta^8 + a9*eta^9 + a10*eta^10)'
    #outputs = exodus
  [../]
  [./total_energy]
    type = DerivativeSumMaterial
    args = 'eta'
    f_name = f_total
    sum_materials = 'f_bulk'
    #outputs = exodus
  [../]
  [./h]
    type = DerivativeParsedMaterial
    args = eta
    f_name = h
    function = 'eta^3*(6*eta^2 - 15*eta + 10)'
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Postprocessors]
  [./dt]
    type = TimestepSize
  [../]
  [./free_energy]
    type = ElementIntegralVariablePostprocessor
    variable = fdens_total
  [../]
  [./free_energy_grad]
    type = ElementIntegralVariablePostprocessor
    variable = fint
  [../]
  [./precip_volume]
    type = ElementIntegralMaterialProperty
    mat_prop = h
  [../]
  [./numDOFs]
    type = NumDOFs
    system = NL
  [../]
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_max_its = 14
  l_max_its = 50
  l_tol = 1e-4
  nl_rel_tol = 1e-8
  end_time = 1.5e6

  [./Adaptivity]
    initial_adaptivity = 4
    coarsen_fraction = 0.1
    refine_fraction = 0.9
    max_h_level = 4
  [../]

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 5.0
    optimal_iterations = 6
    growth_factor = 1.2
    cutback_factor = 0.7
  [../]
[]

[Outputs]
  exodus = true
  interval = 5
  perf_graph = true
[]
