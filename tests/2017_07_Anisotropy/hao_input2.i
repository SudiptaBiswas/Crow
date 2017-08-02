[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 60
  ny = 60
  xmin = -10
  xmax = 10
  ymin = -10
  ymax = 10
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
  [./disp_x]
  [../]
  [./disp_y]
  [../]
[]

[AuxVariables]
  [./total_en]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vonmises_stress]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[ICs]
  [./Circ_e]
    variable = e
    type = SmoothCircleIC
    invalue = 1.0
    outvalue = 0.0
    radius = 1.0
    x1 = 0.0
    y1 = 0.0
    int_width = 0.5
  [../]
  [./Circ_cv]
    variable = cv
    type = SmoothCircleIC
    invalue = 1.0
    outvalue = 0.3
    radius = 1.0
    x1 = 0.0
    y1 = 0.0
    int_width = 0.5
  [../]
  [./Circ_ci]
    variable = ci
    type = SmoothCircleIC
    invalue = 0.0
    outvalue = 0.3
    radius = 1.0
    x1 = 0.0
    y1 = 0.0
    int_width = 0.5
  [../]
[]

[Functions]
  [./load]
    type = PiecewiseLinear
    y = '0.0 6e-4 6e-4'
    x = '0.0 5e-3 1.0'
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
      variable = 'cv wv ci wi e'
      #variable = 'cv wv e'
    [../]
  [../]
  [./left_x]
    type = PresetBC
    variable = disp_x
    boundary = left
    value = 0.0
  [../]
  [./right_x]
    type = FunctionPresetBC
    variable = disp_x
    boundary = right
    #value = 4e-4
    function = load
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

  [./TensorMechanics]
    displacements = 'disp_x disp_y'
  [../]
[]

[AuxKernels]
  [./total_en]
    type = TotalFreeEnergy
    variable = total_en
    interfacial_vars = 'cv e ci'
    kappa_names = 'kappa_c kappa_op kappa_c'
    f_name = F
  [../]
  [./vonmises_stress]
    type = RankTwoScalarAux
    variable = vonmises_stress
    rank_two_tensor = stress
    scalar_type = VonMisesStress
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
    #function = '(e-1.0)^2*(e+1.0)^2*(Ev*cv+kbT*(cv*log(cv)+(1.0-cv)*log(1.0-cv)))
    #            -A*((cv-ceq)^2)*e*(e+2.0)*(e-1.0)^2+B*((cv-1.0)^2)*e^2'
    #args = 'cv e'
    #tol_names = 'cv'
    #tol_values = '0.0001'
    #constant_names = 'Ev kbT A B ceq'
    #constant_expressions = '3e-1 8.617e-2 1.0 3.0 1.5e-16'
    constant_names = 'Ev Ei kbT A B ceq'
    constant_expressions = '3e-1 9e-1 8.617e-3 1.0 3.0 1.5e-16'
    derivative_order = 2
    outputs = exodus
    f_name = Fc
  [../]
  [./Const_mat]
    type = GenericConstantMaterial
    block = 0
    #prop_names = 'kappa_c Mv L kappa_op'
    #prop_values = '0.2 1.0 1.0 0.2'
    prop_names = 'kappa_c Mv Mi L kappa_op'
    prop_values = '0.4 0.2 0.3 0.2 0.4'
  [../]

  [./matrix]
    type = ComputeIsotropicElasticityTensor
    base_name = matrix
    block = 0
    youngs_modulus = 2.4e8
    poissons_ratio = 0.28
  [../]
  [./void]
    type = ComputeIsotropicElasticityTensor
    base_name = void
    block = 0
    youngs_modulus = 1e-8
    poissons_ratio = 0.28
  [../]
  [./Fm]
    type = DerivativeParsedMaterial
    block = 0
    f_name = Fm
    function = '(1-e)^3'
    args = 'e'
  [../]
  [./Fv]
    type = DerivativeParsedMaterial
    block = 0
    f_name = Fv
    function = 'e^2'
    args = 'e'
  [../]
  [./C]
    type = CompositeElasticityTensor
    block = 0
    args = 'e'
    tensors = 'matrix void'
    weights = 'Fm Fv'
  [../]

  [./smallstrain]
    type = ComputeSmallStrain
    block = 0
    displacements = 'disp_x disp_y'
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    block = 0
  [../]
  [./elstc_en]
    type = ElasticEnergyMaterial
    f_name = E
    block = 0
    args = 'e'
    derivative_order = 2
    outputs = exodus
  [../]
  # total energy
  [./sum]
    type = DerivativeSumMaterial
    block = 0
    sum_materials = 'Fc E'
    args = 'cv e ci'
    derivative_order = 2
    outputs = exodus
    f_name = F
  [../]
[]

[Postprocessors]
  [./total_en]
    type = ElementIntegralVariablePostprocessor
    variable = total_en
  [../]
  [./free_chem_en]
    type = ElementIntegralMaterialProperty
    mat_prop = Fc
  [../]
  [./elstc_E]
    type = ElementIntegralMaterialProperty
    mat_prop = E
  [../]
[]

[VectorPostprocessors]
  [./void_size]
    type = LineValueSampler
    start_point = '-10.0 0.0 0.0'
    end_point = '10.0 0.0 0.0'
    sort_by = 'x'
    num_points = 120
    variable = cv
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    #full = true
    coupled_groups = 'cv,wv ci,wi cv,ci,e disp_x,disp_y'
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  end_time = 5
  l_max_its = 20
  nl_max_its = 20
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -sub_pc_factor_shift_type '
  petsc_options_value = 'asm         31   preonly   ilu      1 nonzero'
  #petsc_options_iname = '-snes_type'
  #petsc_options_value = 'test'
  #petsc_options = '-snes_test_display'
  line_search = bt
  dt = 1e-3
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-7
  nl_abs_tol = 1.0e-10
  #[./Adaptivity]
  #  refine_fraction = 0.7
  #  coarsen_fraction = 0.1
  #  max_h_level = 2
  #  initial_adaptivity = 1
  #[../]
[]

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[]

[Debug]
  show_var_residual_norms = true
[]
