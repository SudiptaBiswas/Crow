#
# Example problem showing how to use the DerivativeParsedMaterial with CHParsed.
# The free energy is identical to that from CHMath, f_bulk = 1/4*(1-c)^2*(1+c)^2.
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 256
  ny = 256
  xmin = -64
  xmax = 64
  ymin = -64
  ymax = 64
[]

[Variables]
  active = 'e wv cv T'
  [./cv]
    order = FIRST
    family = LAGRANGE
    block = 0
  [../]
  [./wv]
    order = FIRST
    family = LAGRANGE
    block = 0
  [../]
  [./ci]
    order = FIRST
    family = LAGRANGE
    block = 0
  [../]
  [./wi]
    order = FIRST
    family = LAGRANGE
    block = 0
  [../]
  [./e]
    order = FIRST
    family = LAGRANGE
    block = 0
  [../]
  [./gr0]
    block = 0
  [../]
  [./gr1]
    block = 0
  [../]
  [./T]
    scaling = 1e8
    initial_condition = 800
[]

[AuxVariables]
  active = 'gr0 gr1 bnds'
  [./gr0]
    block = 0
  [../]
  [./gr1]
    block = 0
  [../]
  [./bnds]
    block = 0
  [../]
[]

[AuxKernels]
  [./BndsCalc]
    type = BndsCalcAux
    op_num = 2.0
    var_name_base = gr
    variable = bnds
  [../]
[]

[ICs]
  active = 'PolycrystalICs const_c const_e'
  [./IC_c]
    # int_width = 0.2
    int_width = 5.0
    x1 = 0.0
    y1 = 0.0
    radius = 11.48
    outvalue = 0.113
    variable = cv
    invalue = 0.999
    type = SmoothCircleIC
    block = 0
  [../]
  [./IC_e]
    int_width = 5.0
    x1 = 0
    y1 = 0
    radius = 11.48
    outvalue = 0.0
    variable = e
    invalue = 1.0
    type = SmoothCircleIC
    block = 0
  [../]
  [./rnd_R1]
    variable = R1
    type = RandomIC
    block = 0
  [../]
  [./rand_R2]
    variable = R2
    type = RandomIC
    block = 0
  [../]
  [./const_c]
    variable = cv
    value = 0.113
    type = ConstantIC
    block = 0
  [../]
  [./const_e]
    variable = e
    value = 0.0
    type = ConstantIC
    block = 0
  [../]
  [./PolycrystalICs]
    [./BicrystalBoundingBoxIC]
      var_name_base = gr
      y2 = 64.0
      op_num = 2
      y1 = -64.0
      x2 = 0.0
      x1 = -64.0
    [../]
  [../]
  [./IC_gr0]
    y2 = 64
    x1 = -64
    y1 = -64
    inside = 1.0000
    grain_side = left
    x2 = 0
    variable = gr0
    int_width = 2
    type = BicrystalIC
    block = 0
  [../]
  [./IC_gr1]
    y2 = 64
    x1 = 0
    y1 = -64
    inside = 1.0
    grain_side = right
    x2 = 64
    variable = gr1
    int_width = 2
    type = BicrystalIC
    block = 0
  [../]
[]

[Kernels]
  active = 'AC_int w_res c_dot e_dot c_res CH_noise AC_bulk VacancyAhhihilation heat_cond'
  [./c_dot]
    type = CoupledImplicitEuler
    variable = wv
    v = cv
    block = 0
  [../]
  [./c_res]
    type = SplitCHParsed
    variable = cv
    f_name = F
    kappa_name = kappa_c
    w = wv
    args = e
  [../]
  [./w_res]
    type = SplitCHWRes
    variable = wv
    mob_name = D
  [../]
  [./AC_bulk]
    type = ACParsed
    variable = e
    f_name = F
    args = cv
  [../]
  [./AC_int]
    type = ACInterface
    variable = e
    block = 0
  [../]
  [./e_dot]
    type = TimeDerivative
    variable = e
    block = 0
  [../]
  [./CH_Pv]
    type = VacancySourceTermKernel
    variable = cv
    Vg = 0.25
    eta = e
    block = 0
  [../]
  [./CH_Pv_rand]
    type = RandomVacancySourceTermKernel
    variable = cv
    Vg = 0.1
    eta = e
    block = 0
  [../]
  [./CH_noise]
    type = LangevinNoiseVoid
    variable = cv
    amplitude = 0.1
    block = 0
    eta = e
    Pcasc = 0.25
  [../]
  [./VacancyAhhihilation]
    type = VacancyAnnihilationKernel
    variable = cv
    ceq = 1.13e-4
    v = 'gr0  gr1'
    block = 0
  [../]
  [./heat_cond]
    type = HeatConduction
    variable = T
  [../]
[]

[BCs]
  [./Periodic]
    [./periodic]
      variable = 'cv e wv'
      auto_direction = 'x y'
    [../]
  [../]
  [./T_left]
    type = PresetBC
    variable = T
    boundary = left
    value = 800
  [../]
  [./flux_right]
    type = NeumannBC
    variable = T
    boundary = right
    value = -4.3e-11
  [../]
[]

[Materials]
  active = 'AC_mat Energy_matrix thermal'
  [./Energy_matrix]
    type = DerivativeParsedMaterial
    block = 0
    function = '(e^2-1)^2*(Ef*cv+ kbT*(cv*log(cv)+(1-cv)*log(1-cv))) - A*(cv-cv0)^2*(e^4-3*e^3+2*e)+B*(cv-1)^2*e^2'
    args = 'cv e'
    constant_names = 'Ef   kbT A cv0 B'
    constant_expressions = '9.09  0.11  9.09 1.13e-4 9.09'
    tol_values = 1e-6
    tol_names = cv
    third_derivatives = false
  [../]
  [./Mobility]
    type = PFMobility
    block = 0
    mob = '1.0 '
    kappa = 0.5
  [../]
  [./AC_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'L kappa_op kappa_c D S'
    prop_values = '1.0 1.0 0.5 1.0  1.0'
  [../]
  [./Rand_mat]
    type = RandomVacancySourceTermMaterial
    block = 0
    seed = 1
  [../]
  [./thermal]
    type = ThermalVariation
    block = 0
    GB_conductivity = 1.0
    eta = cv
    v = 'gr0 gr1'
    length_scale = 1e-09
    outputs = exodus
  [../]
[]

[Postprocessors]
  active = 'ElementInt_cv Element_int_eta thcond rprime'
  [./ElementInt_cv]
    type = ElementIntegralVariablePostprocessor
    variable = cv
    block = 0
  [../]
  [./Element_int_eta]
    type = ElementIntegralVariablePostprocessor
    variable = e
  [../]
  [./Nodalflood]
    type = NodalFloodCount
    variable = cv
  [../]
  [./thcond]
    type = ThermalCond
    variable = T
    flux = 4.3e-11
    length_scale = 1e-09
    T_hot = 800
    dx = 250
    boundary = right
  [../]
  [./rprime]
    type = EffectiveKapitzaResistance
    eff_cond = thcond
    ko = 4.5
    dx = 250
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    off_diag_row = 'cv wv'
    off_diag_column = 'wv cv'
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  end_time = 20
  dt = 0.005
  l_max_its = 35
  l_tol = 1.0e-6
  nl_rel_tol = 1.0e-6
  nl_abs_tol = 1.0e-6
[]

[Outputs]
  # print_linear_residuals = true
  exodus = true
  output_on = 'timestep_end initial'
  file_base = RandvoidsourceAnnihilation
  csv = true
  interval = 5
  [./console]
    type = Console
    additional_output_on = initial
  [../]
[]
