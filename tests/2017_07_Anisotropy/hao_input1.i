[Mesh]
  file = IC.e
  parallel_type = replicated
[]

[Functions]
  [./solution_fcn_gr0]
    type = SolutionFunction
    from_variable = 'gr0'
    solution = grainIC
  [../]
  [./solution_fcn_gr1]
    type = SolutionFunction
    from_variable = 'gr1'
    solution = grainIC
  [../]
  [./solution_fcn_gr2]
    type = SolutionFunction
    from_variable = 'gr2'
    solution = grainIC
  [../]
  [./solution_fcn_gr3]
    type = SolutionFunction
    from_variable = 'gr3'
    solution = grainIC
  [../]
  [./solution_fcn_gr4]
    type = SolutionFunction
    from_variable = 'gr4'
    solution = grainIC
  [../]
[]

[Variables]
  [./cv]
  [../]
  [./wv]
  [../]
  [./ci]
  [../]
  [./wi]
  [../]
  [./e]
  [../]
[]

[AuxVariables]
  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr0]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr1]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr2]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr3]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr4]
    order = FIRST
    family = LAGRANGE
  [../]
  [./total_en]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[ICs]
  [./grain_ic_gr0]
    type = FunctionIC
    variable = gr0
    function = solution_fcn_gr0
  [../]
  [./grain_ic_gr1]
    type = FunctionIC
    variable = gr1
    function = solution_fcn_gr1
  [../]
  [./grain_ic_gr2]
    type = FunctionIC
    variable = gr2
    function = solution_fcn_gr2
  [../]
  [./grain_ic_gr3]
    type = FunctionIC
    variable = gr3
    function = solution_fcn_gr3
  [../]
  [./grain_ic_gr4]
    type = FunctionIC
    variable = gr4
    function = solution_fcn_gr4
  [../]
  [./const_e]
    variable = e
    value = 0
    type = ConstantIC
  [../]
  [./cv_ic]
    variable = cv
    value = 0.021
    type = ConstantIC
  [../]
  [./ci_ic]
    variable = ci
    value = 0.021
    type = ConstantIC
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
      variable = 'cv wv ci wi e'
    [../]
  [../]
[]

[Kernels]
  [./cv_dot]
    type = CoupledTimeDerivative
    variable = wv
    v = cv
  [../]
  [./cv_res]
    type = SplitCHParsed
    variable = cv
    f_name = F
    kappa_name = kappa_c
    w = wv
    args = 'e ci'
  [../]
  [./wv_res]
    type = SplitCHWRes
    variable = wv
    mob_name = Mv
    args = 'e ci'
  [../]

  [./ci_dot]
    type = CoupledTimeDerivative
    variable = wi
    v = ci
  [../]
  [./ci_res]
    type = SplitCHParsed
    variable = ci
    f_name = F
    kappa_name = kappa_c
    w = wi
    args = 'e cv'
  [../]
  [./wi_res]
    type = SplitCHWRes
    variable = wi
    mob_name = Mi
    args = 'e cv'
  [../]

  [./AC_bulk]
    type = AllenCahn
    variable = e
    f_name = F
    args = 'cv ci'
  [../]
  [./AC_int]
    type = ACInterface
    variable = e
  [../]
  [./e_dot]
    type = TimeDerivative
    variable = e
  [../]

  [./src_cv]
    type = RadiationDefectSource
    variable = wv
    defect_type = vacancy
  [../]
  [./src_e]
    type = RadiationDefectSource
    variable = e
    defect_type = vacancy
  [../]

  [./VacancyAhhihilation]
    type = VacancyAnnihilationKernel
    variable = wv
    ceq = 1.5e-16
    Svgb = Sv
    v = 'gr0 gr1 gr2 gr3 gr4'
  [../]
  [./InterstitialAhhihilation]
    type = VacancyAnnihilationKernel
    variable = wi
    ceq = 1.5e-16
    Svgb = Si
    v = 'gr0 gr1 gr2 gr3 gr4'
  [../]
[]

[AuxKernels]
  # AuxKernel block, defining the equations used to calculate the auxvars
  [./BndsCalc]
    type = BndsCalcAux
    variable = bnds
    v = 'gr0 gr1 gr2 gr3 gr4'
  [../]
  [./total_en]
    type = TotalFreeEnergy
    variable = total_en
    interfacial_vars = 'cv e ci'
    kappa_names = 'kappa_c kappa_op kappa_c'
    f_name = F
  [../]
[]

[Materials]
  [./Energy_matrix]
    type = DerivativeParsedMaterial
    block = 0
    function = '(e-1.0)^2*(e+1.0)^2*(Ev*cv+Ei*ci+kbT*(cv*log(cv)+ci*log(ci)+(1.0-cv)*log(1.0-cv)+(1.0-ci)*log(1.0-ci)))
                -A*((cv-ceq)^2+(ci-ceq)^2)*e*(e+2.0)*(e-1.0)^2+B*((cv-1.0)^2+ci*(2-ci))*e^2'
    args = 'cv e ci'
    tol_names = 'cv ci'
    tol_values = '0.0001 0.0001'
    constant_names = 'Ev Ei kbT A B ceq'
    constant_expressions = '3.1e-1 9.7e-1 8.617e-3 1.0 3.0 1.5e-16'
    derivative_order = 2
    outputs = exodus
    f_name = F
  [../]
  [./Const_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'kappa_c Mv Mi L kappa_op Sv Si'
    prop_values = '0.4 2.7e-4 3.7 2.7e-4 0.4 100 100'
  [../]
  [./NeutronSrc]
    type = PolyRadiationDefectCreation
    block = 0
    Vg = 0.3
    bottom_left = '-50 -50 0'
    top_right = '50 50 0'
    num_defects = 3
    eta = e
    periodic = true
    v = 'gr0 gr1 gr2 gr3 gr4'
  [../]
[]

[UserObjects]
  [./grainIC]
    type = SolutionUserObject
    mesh = IC.e
    system_variables = 'gr0 gr1 gr2 gr3 gr4'
    timestep = 1
  [../]
[]

[Postprocessors]
  [./porosity]
    type = Porosity
    variable = cv
    execute_on = 'initial TIMESTEP_END'
  [../]
  [./total_en]
    type = ElementIntegralVariablePostprocessor
    variable = total_en
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    coupled_groups = 'cv,wv ci,wi cv,ci,e'
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  end_time = 0.017
  l_max_its = 20
  nl_max_its = 20
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  dt = 1e-4
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-8
  nl_abs_tol = 1.0e-10
[]

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[]

[Debug]
  show_var_residual_norms = true
[]
