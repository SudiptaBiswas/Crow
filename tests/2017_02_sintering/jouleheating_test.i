[GlobalParams]
  block = '0 1'
[]


[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 40
  ny = 20
  xmax = 20
  ymax = 10
  uniform_refine = 2
[]

[MeshModifiers]
  [./subdomain1]
    type = SubdomainBoundingBox
    bottom_left = '0.0 0.0 0.0'
    top_right = '2.0 10.0 0.0'
    block_id = 1
  [../]
  #[./subdomain2]
  #  type = SubdomainBoundingBox
  #  bottom_left = '330 0 0'
  #  top_right = '350 200 0'
  #  block_id = 2
  #[../]
[]

[Variables]
  [./T]
    initial_condition = 300.0
    #scaling = 1e15
  [../]
  [./elec]
    #initial_condition = 1.0
  [../]
[]

[Kernels]
  [./HeatDiff]
    type = MatDiffusion
    variable = T
    #args = 'c'
    D_name = thermal_conductivity
  [../]
  [./HeatTdot]
    type = HeatConductionTimeDerivative
    variable = T
  [../]
  #[./heatsource]
  #  type = HeatSource
  #  block = 1
  #  function = volumetric_heat
  #  variable = T
  #[../]
  #[./elec_source]
  #  type = HeatSource
  #  block = 1
  #  function = volumetric_heat1
  #  variable = elec
  #[../]
  [./HeatSrc]
    type = JouleHeatingSource
    variable = T
    elec = elec
  [../]
  [./electric]
    type = MatDiffusion
    variable = elec
    D_name = electrical_conductivity
    args = 'T'
  [../]
  [./elec_dot]
    type = CoefTimeDerivative
    variable = elec
    #Coefficient = 0.1
  [../]
[]

[AuxVariables]
  [./grade_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./grade_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  #[./c]
  #[../]
[]

[AuxKernels]
  [./grade_x]
    type = VariableGradientComponent
    variable = grade_x
    gradient_variable = elec
    component = x
  [../]
  [./grade_y]
    type = VariableGradientComponent
    variable = grade_y
    gradient_variable = elec
    component = y
  [../]
[]

[Functions]
  [./volumetric_heat]
     type = ParsedFunction
     value = 2.0
  [../]
  [./volumetric_heat1]
     type = ParsedFunction
     value = 0.5
  [../]
[]

#[ICs]
#  [./c]
#    type = SmoothCircleIC
#    variable = c
#    invalue = 0.0
#    outvalue = 1.0
#    x1 = 5.0
#    y1 = 5.0
#    radius = 3.0
#    int_width = 0.8
#  [../]
#  #[./elec]
#  #  type = RandomIC
#  #  variable = elec
#  #[../]
#[]


[BCs]
  #[./lefttemp]
  #  type = DirichletBC
  #  boundary = left
  #  variable = T
  #  value = 300
  #[../]
  [./elec_left]
    type = DirichletBC
    variable = elec
    boundary = right
    value = 0.05
  [../]
  #[./elec_right]
  #  type = NeumannBC
  #  variable = elec
  #  boundary = left
  #  value = 0.5
  #[../]
  #[./elec_right]
  #  type = CahnHilliardFluxBC
  #  variable = elec
  #  boundary = 'right'
  #  flux = '0.5 0 0'
  #  mob_name = electrical_conductivity
  #  args = 'T'
  #[../]
  #[./elec_top]
  #  type = CahnHilliardFluxBC
  #  variable = elec
  #  boundary = 'top'
  #  flux = '0 1.0 0'
  #  mob_name = electrical_conductivity
  #  args = 'T'
  #[../]
[]

[Materials]
  #[./k]
  #  type = GenericConstantMaterial
  #  prop_names = 'thermal_conductivity'
  #  prop_values = '0.95' #copper in cal/(cm sec C)
  #  block = 0
  #[../]
  #[./cp]
  #  type = GenericConstantMaterial
  #  prop_names = 'specific_heat'
  #  prop_values = '0.092' #copper in cal/(g C)
  #  block = 0
  #[../]
  #[./heatcond]
  #  type = HeatConductionMaterial
  #  block = 0
  #  thermal_conductivity = 0.08
  #  specific_heat = 0.01
  #  outputs = exodus
  #[../]
  #[./density]
  #  type = Density
  #  block = 0
  #  density = 10.0
  #  outputs = exodus
  #[../]
  #[./rho]
  #  type = GenericConstantMaterial
  #  prop_names = 'density'
  #  prop_values = '8.92' #copper in g/(cm^3)
  #  block = 0
  #[../]
  #[./sigma]
  #  type = ElectricalConductivity
  #  temp = T
  #  ref_temp = 300
  #  ref_resistivity = 0.0168
  #  temp_coeff = 0.00386
  #  length_scale = 1.0
  #  base_name = phase1
  #  outputs = exodus
  #  output_properties = 'electrical_conductivity'
  #[../]
  #[./constant_mat]
  #  type = GenericConstantMaterial
  #  prop_names = '  therm_cond_phase1   density_phase1  spcfc_ht_phase1  phase1_electrical_conductivity'
  #  prop_values = '      0.08           10.0              0.01              1.0 '
  #[../]
  [./constant_mat]
    type = GenericConstantMaterial
    prop_names = '  thermal_conductivity   density  specific_heat  electrical_conductivity'
    prop_values = '      0.08               10.0        0.01              1.0 '
  [../]
  #[./elec_bc]
  #  type = ElectricBCMat
  #  elec = elec
  #  c = c
  #  bc_type = Neumann
  #  left_function = volumetric_heat
  #  right_function = volumetric_heat1
  #  #top_function = volumetric_heat
  #  #bottom_function = volumetric_heat1
  #  boundary_side = 'Left Right'
  #  outputs = exodus
  #[../]
  #[./switching]
  #  type = DerivativeParsedMaterial
  #  f_name = h
  #  args = c
  #  function = 'c'
  #[../]
  #
  #[./therm_cond]
  #  type = DerivativeTwoPhaseMaterial
  #  W = 0
  #  eta = c
  #  args = 'T'
  #  f_name = thermal_conductivity
  #  fa_name = 1e-14
  #  fb_name = therm_cond_phase1
  #  g = 0.0
  #  #h = 0.8
  #  outputs = exodus
  #  derivative_order = 2
  #[../]
  #
  #[./elec_cond]
  #  type = DerivativeTwoPhaseMaterial
  #  W = 0
  #  eta = c
  #  args = 'T'
  #  f_name = electrical_conductivity
  #  fa_name = 1e-14
  #  fb_name = phase1_electrical_conductivity
  #  g = 0.0
  #  #h = 0.8
  #  outputs = exodus
  #  derivative_order = 2
  #[../]
  #[./dens]
  #  type = DerivativeTwoPhaseMaterial
  #  W = 0
  #  eta = c
  #  args = 'T'
  #  f_name = density
  #  fa_name = 1e-14
  #  fb_name = density_phase1
  #  g = 0.0
  #  #h = 0.8
  #  outputs = exodus
  #  derivative_order = 2
  #[../]
  #[./spcfc_ht]
  #  type = DerivativeTwoPhaseMaterial
  #  W = 0
  #  eta = c
  #  args = 'T'
  #  f_name = specific_heat
  #  fa_name = 1e-4
  #  fb_name = spcfc_ht_phase1
  #  g = 0.0
  #  #h = 0.8
  #  outputs = exodus
  #  derivative_order = 2
  #[../]
  [./grad_elc]
    type = VariableGradientMaterial
    prop = grad_elc
    variable = elec
  [../]
  [./current]
    type = DerivativeParsedMaterial
    material_property_names = 'electrical_conductivity grad_elc'
    f_name = current_prop
    function = 'electrical_conductivity*grad_elc'
    outputs = exodus
  [../]
  [./joule_heat]
    type = DerivativeParsedMaterial
    material_property_names = 'electrical_conductivity grad_elc'
    f_name = joule_heat
    function = 'electrical_conductivity*grad_elc*grad_elc'
    outputs = exodus
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
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -sub_pc_factor_shift_type'
  petsc_options_value = 'asm         31                 preonly         lu          1              NONZERO'
  #petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  #petsc_options_value = '201                hypre    boomeramg      8'

  #petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  #petsc_options_value = 'lu       superlu_dist'
  #petsc_options = '-ksp_converged_reason'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-4
  l_max_its = 20
  nl_max_its = 20
  dt = 1
  end_time = 500
[]

#[Adaptivity]
#  marker = errorfrac
#  max_h_level = 3
#  [./Indicators]
#    [./error]
#      type = GradientJumpIndicator
#      variable = elec
#    [../]
#  [../]
#  [./Markers]
#    #[./bound_adapt]
#    #  type = ValueRangeMarker
#    #  upper_bound = 0.9
#    #  lower_bound = 0.0
#    #  variable = c
#    #[../]
#    [./errorfrac]
#      type = ErrorFractionMarker
#      coarsen = 0.1
#      indicator = error
#      refine = 0.7
#    [../]
#  [../]
#[]


[Outputs]
  #exodus = true
  print_perf_log = true
  [./exodus]
    type = Exodus
    elemental_as_nodal = true
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
