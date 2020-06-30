[GlobalParams]
  var_name_base = gr
  op_num = 8.0
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 60
  ny = 30
  nz = 0
  xmin = 0.0
  xmax = 30.0
  ymin = 0.0
  ymax = 15
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
  [./PolycrystalVariables]
  [../]
  [./disp_x]
    block = 0
  [../]
  [./disp_y]
    block = 0
  [../]
[]

[AuxVariables]
  [./bnds]
  [../]
  [./total_en]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./e11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./e22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./S11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./S22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./T]
  [../]
[]

[Functions]
  [./load]
    type = PiecewiseLinear
    y = '1.0 1.0 1.0 1.0'
    x = '0.0 5.0 20.0 60.0 '
  [../]
  [./temp]
    type = PiecewiseLinear
    y = '300.0 673.0 1673.0 1673.0 673.0 300.0'
    x = '0.0 5.32 21.26 45.51 50.69 60.0'
  [../]
[]

[Preconditioning]
  active = 'SMP'
  [./PBP]
    type = PBP
    solve_order = 'w c'
    preconditioner = 'AMG ASM'
    off_diag_row = 'c '
    off_diag_column = 'w '
  [../]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Kernels]
  [./cres]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa_c
    w = w
    f_name = F
    args = 'gr0  gr1 gr2 gr3 gr4 gr5 gr6 gr7'
  [../]
  [./wres]
    type = SplitCHWRes
    variable = w
    mob_name = D
  [../]
  [./time]
    type = CoupledTimeDerivative   # CoupledImplicitEuler
    variable = w
    v = c
  [../]
  [./PolycrystalSinteringKernel]
    c = c
    v = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7'
  [../]
  [./TensorMechanics]
    disp_y = disp_y
    disp_x = disp_x
  [../]
  [./Elstc_gr0]
    type = ACParsed
    variable = gr0
    f_name = E
    args = 'c gr1 gr2 gr3 gr4 gr5 gr6 gr7'
  [../]
  [./Elstc_gr1]
    type = ACParsed
    variable = gr1
    f_name = E
    args = 'c gr0 gr2 gr3 gr4 gr5 gr6 gr7'
  [../]
  [./Elstc_gr2]
    type = ACParsed
    variable = gr2
    f_name = E
    args = 'c gr0 gr1 gr3 gr4 gr5 gr6 gr7'
  [../]
  [./Elstc_gr3]
    type = ACParsed
    variable = gr3
    f_name = E
    args = 'c gr0 gr1 gr2 gr4 gr5 gr6 gr7'
  [../]
  [./Elstc_gr4]
    type = ACParsed
    variable = gr4
    f_name = E
    args = 'c gr0 gr1 gr1 gr3 gr5 gr6 gr7'
  [../]
  [./Elstc_gr5]
    type = ACParsed
    variable = gr5
    f_name = E
    args = 'c gr0 gr1 gr2 gr3 gr4 gr6 gr7'
  [../]
  [./Elstc_gr6]
    type = ACParsed
    variable = gr6
    f_name = E
    args = 'c gr0 gr1 gr2 gr3 gr4 gr5 gr7'
  [../]
  [./Elstc_gr7]
    type = ACParsed
    variable = gr7
    f_name = E
    args = 'c gr0 gr1 gr2 gr3 gr4 gr5 gr6'
  [../]
[]

[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    v = 'gr0 gr1 gr2 gr3 gr4  gr5 gr6 gr7'
  [../]
  [./Total_en]
    type = TotalFreeEnergy
    variable = total_en
    kappa_names = 'kappa_c kappa_op kappa_op kappa_op kappa_op kappa_op kappa_op kappa_op kappa_op'
    interfacial_vars = 'c gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7'
  [../]
  [./e11]
    type = RankTwoAux
    variable = e11
    rank_two_tensor = total_strain
    index_j = 0
    index_i = 0
    block = 0
  [../]
  [./e22]
    type = RankTwoAux
    variable = e22
    rank_two_tensor = total_strain
    index_j = 1
    index_i = 1
    block = 0
  [../]
  [./S11]
    type = RankTwoAux
    variable = S11
    rank_two_tensor = stress
    index_j = 0
    index_i = 0
    block = 0
  [../]
  [./S22]
    type = RankTwoAux
    variable = S22
    rank_two_tensor = stress
    index_j = 1
    index_i = 1
    block = 0
  [../]
  [./T]
    type = FunctionAux
    variable = T
    function = temp
    block = 0
  [../]
[]

[BCs]
  [./Disp_x]
    type = PresetBC
    variable = disp_x
    boundary = 'right left'
    value = 0.0
  [../]
  [./Disp_y]
    type = PresetBC
    variable = disp_y
    boundary = bottom
    value = 0.0
  [../]
  [./PressureTM]
    [./pressure]
      function = load
      boundary = top
      disp_y = disp_y
      disp_x = disp_x
    [../]
  [../]
[]

[Materials]
  active = 'AC_mat Eigen temp Elstc_en sum CH_mat free_energy'
  [./constant]
    type = PFMobility
    block = 0
    mob = 1.0
    kappa = 2.0
  [../]
  [./free_energy]
    type = SinteringFreeEnergy
    block = 0
    c = c
    v = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7'
    f_name = S
    derivative_order = 2
  [../]
  [./CH_mat]
    type = PFDiffusionGrowth
    block = 0
    rho = c
    v = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7'
  [../]
  [./AC_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'L kappa_op'
    prop_values = '1.0 0.5'
  [../]
  [./temp]
    type = DerivativeParsedMaterial
    block = 0
    constant_expressions = 8.617e-5
    fail_on_evalerror = true
    function = kb*T*(c*log(c)+(1-c)*log(1-c))
    f_name = Ft
    args = 'c  T'
    constant_names = kb
    tol_values = 1e-3
    tol_names = c
    derivative_order = 2
  [../]
  [./sum]
    type = DerivativeSumMaterial
    block = 0
    sum_materials = 'S Ft E'
    args = 'c gr0 gr1'
    derivative_order = 2
  [../]
  [./Eigen]
    type = PFEigenStrainMaterial1
    block = 0
    c = c
    disp_y = disp_y
    disp_x = disp_x
    epsilon0 = 0.05
    C_ijkl = '153e-2 180e-2'
    fill_method = symmetric_isotropic
    v = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7'
    e_v = 0.01
    thermal_expansion_coeff = 4.3e-6
    T = T
  [../]
  [./Elstc_en]
    type = ElasticEnergyMaterial
    block = 0
    f_name = E
    args = 'c gr0 gr1 gr2 gr3 gr4 gr5  gr6 gr7'
    derivative_order = 2
  [../]
[]

[Postprocessors]
  [./mat_D]
    type = ElementIntegralMaterialProperty
    mat_prop = D
  [../]
  [./elem_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
  [../]
  [./elem_bnds]
    type = ElementIntegralVariablePostprocessor
    variable = bnds
  [../]
  [./elem_gr0]
    type = ElementIntegralVariablePostprocessor
    variable = gr0
  [../]
  [./Eleem_var_gr1]
    type = ElementIntegralVariablePostprocessor
    variable = gr1
  [../]
  [./load]
    type = PlotFunction
    function = load
  [../]
  [./temp]
    type = PlotFunction
    function = temp
  [../]
  [./s11]
    type = ElementAverageValue
    variable = S11
  [../]
  [./s22]
    type = ElementAverageValue
    variable = S22
  [../]
  [./e11]
    type = ElementAverageValue
    variable = e11
  [../]
  [./e22]
    type = ElementAverageValue
    variable = e22
  [../]
  [./bnds_avg]
    type = ElementAverageValue
    variable = bnds
  [../]
  [./dispx_avg]
    type = AverageNodalVariableValue
    variable = disp_x
  [../]
  [./dispy_avg]
    type = AverageNodalVariableValue
    variable = disp_y
  [../]
  [./dispy_top]
    type = SideAverageValue
    variable = disp_y
    boundary = top
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  scheme = BDF2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  l_max_its = 30
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-10
  dt = 0.05
  num_steps = 10000
  end_time = 60
  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 0.05
  [../]
[]

[Outputs]
  exodus = true
  output_on = 'initial timestep_end'
  [./console]
    type = Console
    perf_log = true
    output_on = 'timestep_end failed nonlinear linear'
    file_base = comb_multip
  [../]
[]

[ICs]
  active = 'PolycrystalICs multip'
  [./PolycrystalICs]
    [./MultiSmoothParticleIC]
      x_positions = '4.0 11.0 18.0 25.0 4.0 11.0 18.0 25.0'
      z_positions = 0
      radii = '3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0'
      y_positions = '4.0 4.0 4.0 4.0 11.0 11.0 11.0 11.0'
      3D_spheres = false
      int_width = 1.0
    [../]
  [../]
  [./2p_dens]
    radius = '5.0 5.0 '
    variable = c
    type = TwoParticleDensityIC
    block = 0
    tol = 1e-3
  [../]
  [./multip]
    x_positions = '4.0 11.0 18.0 25.0 4.0 11.0 18.0 25.0'
    int_width = 1.0
    z_positions = 0
    y_positions = '4.0 4.0 4.0 4.0 11.0 11.0 11.0 11.0'
    radii = '3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0'
    3D_spheres = false
    outvalue = 0.001
    variable = c
    invalue = 0.999
    type = SpecifiedSmoothCircleIC
    block = 0
  [../]
[]

