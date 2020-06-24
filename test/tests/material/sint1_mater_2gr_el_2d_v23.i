[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 60
  ny = 60
  xmin = 4.0
  xmax = 33.0
  ymin = 8.0
  ymax = 34.0
  elem_type = QUAD4
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  var_name_base = gr
  op_num = 2.0
  int_width = 1.0
[]

[Variables]
  [./c]
    #scaling = 10
  [../]
  [./w]
  [../]
  [./PolycrystalVariables]
  [../]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]
  [./temp]
    initial_condition = 400
  [../]
[]

[ICs]
  [./ic_gr1]
    int_width = 2.0
    x1 = 12.592
    y1 = 22.4133
    radius = 6.25
    outvalue = 0.01
    variable = gr1
    invalue = 0.99
    type = SmoothCircleIC
  [../]
  [./ic_gr0]
    int_width = 2.0
    x1 = 24.6702
    y1 = 24.1294
    radius = 6.25
    outvalue = 0.01
    variable = gr0
    invalue = .99
    type = SmoothCircleIC
  [../]
  [./multip]
    x_positions = '12.592	24.6702'
    y_positions = '22.4133	24.1294'
    z_positions = '0 0'
    radii = '6.25	8.25'
    int_width = 2.0
    3D_spheres = false
    outvalue = 0.01
    variable = c
    invalue = 0.99
    type = SpecifiedSmoothCircleIC
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
  [./unique_grains]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./var_indices]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./centroids]
    order = CONSTANT
    family = MONOMIAL
  [../]
    [./sigma11_aux]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./sigma22_aux]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = 0.01
  [../]
[]

[Kernels]
  [./heat]
    type = HeatConduction
    variable = temp
  [../]
  [./HeatSource]
    type = HeatSource
    function = '10*exp(-((x-(31-2.7*t))^2/2))*exp(-abs(y-34)/1)'
    variable = temp
  [../]
  [./TensorMechanics]
    displacements = 'disp_x disp_y'
  [../]
  [./cres]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa_c
    w = w
    f_name = F
    args = 'gr0 gr1'
  [../]
  [./wres]
    type = SplitCHWRes
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
    anisotropic = false
    grain_force = grain_force
    grain_tracker_object = grain_center
    grain_volumes = grain_volumes
    translation_constant = 10.0
    rotation_constant = 1.0
  [../]
[]

[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    v = 'gr0 gr1 '
  [../]
  [./Total_en]
    type = TotalFreeEnergy
    variable = total_en
    kappa_names = 'kappa_c kappa_op kappa_op '
    interfacial_vars = 'c  gr0 gr1 '
  [../]
  [./unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    flood_counter = grain_center
    field_display = UNIQUE_REGION
    execute_on = timestep_begin
  [../]
  [./var_indices]
    type = FeatureFloodCountAux
    variable = var_indices
    flood_counter = grain_center
    field_display = VARIABLE_COLORING
    execute_on = timestep_begin
  [../]
  [./centroids]
    type = FeatureFloodCountAux
    variable = centroids
    execute_on = timestep_begin
    field_display = CENTROID
    flood_counter = grain_center
  [../]
  [./matl_sigma11]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 0
    index_j = 0
    variable = sigma11_aux
  [../]
  [./matl_sigma22]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 1
    index_j = 1
    variable = sigma22_aux
  [../]
[]

[BCs]
# Boundary Condition block
  [./Periodic]
    [./left_right]
      auto_direction = 'x ' # Makes problem periodic in the x and y directions
    [../]
  [../]
  [./bottom]
    type = DirichletBC
    variable = temp
    boundary = bottom
    value = 700
  [../]
[]

[Materials]
  [./sumofgr]
    type = DerivativeParsedMaterial
    f_name = sumofgr
    args = 'gr0 gr1'
    function = (gr0^2+gr1^2)
    derivative_order = 2
  [../]
  [./chemical_free_energy]
    type = DerivativeParsedMaterial
    f_name = Fc
    args = 'c gr0 gr1'
    constant_names = 'A  B'
    constant_expressions = '16.0 1.0'
    material_property_names = 'sumofgr'
    function = A*c^2*(1-c)^2+B*(c^2+6*(1-c)*sumofgr-4*(2-c)*(gr0^3+gr1^3)+3*sumofgr^2)
    derivative_order = 2
  [../]
  # [./Dv]
  [./CH_mat]
    type = PFDiffusionGrowthM3
    block = 0
    Dvol = 0.01
    rho = c
    T = temp
    v = 'gr0 gr1'
    outputs = console
  [../]
  [./constant_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = '  A    B   L    kappa_op kappa_c'
    prop_values = ' 16.0 1.0 1.0  0.5      1.0    '
  [../]
  [./elasticity_tensor]
    type = ComputeElasticityTensor
    block = 0
    # lambda, mu values
    C_ijkl = '7 7'
    # Stiffness tensor is created from lambda=7, mu=7 using symmetric_isotropic fill method
    fill_method = symmetric_isotropic
    # See RankFourTensor.h for details on fill methods
    # '15 15' results in a high stiffness (the elastic free energy will dominate)
    # '7 7' results in a low stiffness (the chemical free energy will dominate)
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    block = 0
  [../]
#     [./var_dependence]
#     type = DerivativeParsedMaterial
#     block = 0
#     function = 0.2*c
#     args = c
#     f_name = var_dep
#     enable_jit = true
#     derivative_order = 2
#   [../]
  [./strain]
    type = ComputeSmallStrain
    # block = 0
    displacements = 'disp_x disp_y'
    eigenstrain_names = eigenstrain
  [../]
  [./elastic_free_energy]
    type = ElasticEnergyMaterial
    f_name = Fe
    block = 0
    args = 'c'
    derivative_order = 2
  [../]
  # Sum up chemical and elastic contributions
  [./free_energy]
    type = DerivativeSumMaterial
    block = 0
    f_name = F
    sum_materials = 'Fc Fe'
    args = 'c'
    derivative_order = 2
  [../]
  [./thermal_strain]
    type = ComputeThermalExpansionEigenstrain
    block = 0
    # eigen_base = '1 1 1 0 0 0'
    # prefactor = var_dep
    temperature = temp
    # outputs = exodus
    # args = 'c'
    stress_free_temperature = 400
    thermal_expansion_coeff = 1e-8
    eigenstrain_name = eigenstrain
  [../]
  [./heat]
    type = HeatConductionMaterial
    block = 0
    specific_heat = 1.0
    thermal_conductivity = 1.0
  [../]
  [./poissons_ratio]
    type = PiecewiseLinearInterpolationMaterial
    x = '100 500'
    y = '0   0.25'
    property = poissons_ratio
    variable = temp
  [../]
[]

[VectorPostprocessors]
  [./grain_volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = grain_center
    execute_on = 'initial timestep_begin'
  [../]
  # undersized solute (voidlike)
[]

[UserObjects]
  [./grain_center]
    type = GrainTracker
    outputs = none
    compute_var_to_feature_map = true
    execute_on = 'initial timestep_begin'
  [../]
[]

[Postprocessors]
  [./elem_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
  [../]
  [./elem_bnds]
    type = ElementIntegralVariablePostprocessor
    variable = bnds
  [../]
  [./total_energy]
    type = ElementIntegralVariablePostprocessor
    variable = total_en
  [../]
  [./free_en]
    type = ElementIntegralMaterialProperty
    mat_prop = F
  [../]
  [./el_free_en]
    type = ElementIntegralMaterialProperty
    mat_prop = Fe
  [../]
  [./ch_free_en]
    type = ElementIntegralMaterialProperty
    mat_prop = Fc
  [../]
  [./dofs]
    type = NumDOFs
    system = 'NL'
  [../]
  [./tstep]
    type = TimestepSize
  [../]
  [./int_area]
    type = InterfaceAreaPostprocessor
    variable = c
  [../]
  [./grain_size_gr0]
    type = ElementIntegralVariablePostprocessor
    variable = gr0
  [../]
  [./grain_size_gr1]
    type = ElementIntegralVariablePostprocessor
    variable = gr1
  [../]
  [./gb_area]
    type = GrainBoundaryArea
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    coupled_groups = 'c,w c,gr0,gr1 '
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  scheme = BDF2
  # solve_type = NEWTON
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  l_max_its = 15
  nl_max_its = 15
  nl_abs_tol = 1e-04
  nl_rel_tol = 1e-04
  l_tol = 1e-04
  end_time = 10
  #dt = 0.01
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.05
    growth_factor = 1.15
  [../]
[]

[Adaptivity]
  marker = bound_adapt
  max_h_level = 2
  [./Indicators]
    [./error]
      type = GradientJumpIndicator
      variable = bnds
    [../]
  [../]
  [./Markers]
    [./bound_adapt]
      type = ValueRangeMarker
      lower_bound = 0.01
      upper_bound = 0.99
      variable = bnds
    [../]
  [../]
[]

[Outputs]
  print_linear_residuals = true
  csv = true
  # exodus = true
  gnuplot = true
  print_perf_log = true
  [./console]
    type = Console
    perf_log = true
  [../]
  [./exodus]
    type = Exodus
    elemental_as_nodal = true
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
