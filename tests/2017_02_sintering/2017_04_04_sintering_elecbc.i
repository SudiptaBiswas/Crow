[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 80
  ny = 40
  nz = 0
  xmin = 0.0
  xmax = 40.0
  ymin = 0.0
  ymax = 20.0
  zmax = 0
  #uniform_refine = 2
  elem_type = QUAD4
[]

[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  block = '0'
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
  [./gr0]
  [../]
  [./gr1]
  [../]
  [./T]
    initial_condition = 1200.0
  [../]
  [./elec]
  [../]
[]

[AuxVariables]
  [./bnds]
  [../]
  [./gradc_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./gradc_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    v = 'gr0 gr1'
  [../]
  [./gradc_x]
    type = VariableGradientComponent
    variable = gradc_x
    gradient_variable = c
    component = x
  [../]
  [./gradc_y]
    type = VariableGradientComponent
    variable = gradc_y
    gradient_variable = c
    component = y
  [../]
[]

[ICs]
  #[./ic_c]
  #  int_width = 2.0
  #  x1 = 10.0
  #  y1 = 10.0
  #  radius = 7.4
  #  outvalue = 0.0
  #  variable = c
  #  invalue = 1.0
  #  type = SmoothCircleIC
  #[../]
  [./multip]
    type = SpecifiedSmoothCircleIC
    x_positions = '10.0 25.0'
    int_width = 2.0
    z_positions = '0 0'
    y_positions = '10.0 10.0 '
    radii = '7.4 7.4'
    3D_spheres = false
    outvalue = 0.001
    variable = c
    invalue = 0.999
  [../]
  [./ic_gr1]
    type = SmoothCircleIC
    int_width = 2.0
    x1 = 25.0
    y1 = 10.0
    radius = 7.4
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
  [../]
  [./ic_gr0]
    type = SmoothCircleIC
    int_width = 2.0
    x1 = 10.0
    y1 = 10.0
    radius = 7.4
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
  [../]
[]

[Kernels]
  [./cres]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa_c
    w = w
    f_name = F
    args = 'gr0 gr1'
  [../]
  [./wres]
    type = SplitCHWResAniso
    variable = w
    mob_name = D
  [../]
  [./time]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./PolycrystalSinteringKernel]
    c = c
    consider_rigidbodymotion = false
  [../]
  [./HeatDiff]
    type = HeatConduction
    variable = T
  [../]
  [./HeatTdot]
    type = HeatConductionTimeDerivative
    variable = T
  [../]
  [./HeatSrc]
    type = JouleHeatingSource
    variable = T
    elec = elec
  [../]
  [./electric]
    type = HeatConduction
    variable = elec
    diffusion_coefficient = electrical_conductivity
  [../]
  [./electric_bc]
    type = ElectricBCKernel
    variable = elec
  [../]
[]

[BCs]
  [./flux_ch]
    type = CahnHilliardAnisoFluxBC
    variable = w
    boundary = 'top bottom right left'
    flux = '0 0 0'
    mob_name = D
    args = 'c gr0 gr1'
  [../]
[]

[Functions]
  [./volumetric_heat]
     type = ParsedFunction
     value = -1.0
  [../]
  [./volumetric_heat1]
     type = ParsedFunction
     value = 1.0
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
    type = ElectricalConductivity
    temp = T
    ref_temp = 300
    ref_resistivity = 0.0168
    temp_coeff = 0.00386
    length_scale = 1e-02
    outputs = exodus
  [../]
  [./elec_bc]
    type = ElectricBCMat
    elec = elec
    c = c
    #bc_type = Neumann
    left_function = volumetric_heat
    right_function = volumetric_heat1
    top_function = volumetric_heat
    bottom_function = volumetric_heat1
    boundary_side = 'Left Right Top Bottom'
    outputs = exodus
  [../]
  [./free_energy]
    type = SinteringFreeEnergy
    c = c
    v = 'gr0 gr1'
    #A = A
    #B = B
    #f_name = S
    derivative_order = 2
    #outputs = console
  [../]
  [./constant_mat]
    type = GenericConstantMaterial
    prop_names = '  A         B       kappa_op    kappa_c  L '
    prop_values = '16.0       1.0       0.5         1.0   1.0'
    #prop_names = '  A    B  '
    #prop_values = '16.0 1.0 '
  [../]
  [./mob]
    type = SinteringMtrxMobility
    T = T
    int_width = 2
    #GB_energy = 6.86
    #surface_energy = 9.33
    GBmob0 = 3.986e-6
    Qv = 2.0
    Qgb = 4.143
    Qs = 3.14
    Qgbm = 0.94
    Dgb0 = 4.0e-4
    Dsurf0 = 1.41e-5
    Dvap0 = 4.0e-6
    Dvol0 = 4.0e-6
    c = c
    v = 'gr0 gr1'
    Vm = 1.5829e-29
    length_scale = 1e-08
    time_scale = 1e-4
    bulkindex = 1.0
    surfindex = 1.0
    gbindex = 1.0
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
  scheme = BDF2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -sub_pc_factor_shift_type '
  petsc_options_value = 'asm         31   preonly   lu      1 nonzero'
  #petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap '
  #petsc_options_value = 'asm         31   preonly   lu      1'
  petsc_options = '-snes_converged_reason'
  #petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  #petsc_options_value = 'lu       superlu_dist'
  l_max_its = 20
  nl_max_its = 20
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-08
  l_tol = 1e-04
  end_time = 500
  #dt = 0.01
  #dtmax = 2.0
  dtmin = 1e-4
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.1
    growth_factor = 1.2
  [../]
[]

[Outputs]
  #exodus = true
  print_perf_log = true
  print_linear_residuals = true
  [./exodus]
    type = Exodus
    elemental_as_nodal = true
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
