[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 60
  ny = 60
  #   nz = 0
  xmin = 60.0
  xmax = 330.0
  ymin = 130.0
  ymax = 340.0
  # zmax = 0
  elem_type = QUAD4
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  var_name_base = gr
  op_num = 9.0
  int_width = 1.0
  #en_ratio = 1
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
[]

[ICs]
  [./ic_gr8]
    int_width = 20.0
    x1 = 280.9158
    y1 = 180.2981
    radius = 36.895
    outvalue = 0.0
    variable = gr8
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./ic_gr7]
    int_width = 20.0
    x1 = 100.6328
    y1 = 290.4843
    radius = 36.75
    outvalue = 0.0
    variable = gr7
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./ic_gr6]
    int_width = 20.0
    x1 = 21.7174
    y1 = 15.3236
    radius = 36.75
    outvalue = 0.0
    variable = gr6
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./ic_gr5]
    int_width = 20.0
    x1 = 200.0109
    y1 = 300.5594
    radius = 40.32
    outvalue = 0.0
    variable = gr5
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./ic_gr4]
    int_width = 20.0
    x1 = 270.8199
    y1 = 280.1836
    radius = 36.375
    outvalue = 0.0
    variable = gr4
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./ic_gr3]
    int_width = 20.0
    x1 = 220.0109
    y1 = 220.7441
    radius = 36.375
    outvalue = 0.0
    variable = gr3
    invalue = 1.0
    type = SmoothCircleIC
  [../]
 [./ic_g2]
    int_width = 20.0
    x1 = 130.5818
    y1 = 170.6532
    radius = 36.375
    outvalue = 0.0
    variable = gr2
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./ic_gr1]
    int_width = 20.0
    x1 = 80.592
    y1 = 220.4133
    radius = 36.25
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./ic_gr0]
    int_width = 20.0
    x1 = 150.6702
    y1 = 240.1294
    radius = 36.25
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./multip]
    x_positions = '280.9158 100.6328	210.7174	200.0109	270.8199	220.9458	130.5818	8.592	   150.6702'
    y_positions = '180.2981 290.4843	150.3236	300.5594	280.1836	220.7441	170.6532	220.4133	240.1294'
    z_positions = '0 0 0 0 0 0 0 0 0'
    radii = '36.875	36.75	36.75	40.325	36.5	36.375	36.375	36.25	36.25'
    int_width = 20.0
    3D_spheres = false
    outvalue = 0.001
    variable = c
    invalue = 0.999
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

[Kernels]
  [./TensorMechanics]
    displacements = 'disp_x disp_y'
  [../]
  [./gravity_y]
    type = Gravity
    variable = disp_y
    # value = -0.2 # 1.81
    value = -9.0 # 1.81
  [../]
  [./cres]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa_c
    w = w
    f_name = F
    args = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8'
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
    v = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8'
  [../]
  [./Total_en]
    type = TotalFreeEnergy
    variable = total_en
    kappa_names = 'kappa_c kappa_op kappa_op kappa_op kappa_op kappa_op kappa_op kappa_op kappa_op kappa_op'
    interfacial_vars = 'c  gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8'
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
    [./top_bottom]
      auto_direction = 'x' # Makes problem periodic in the x and y directions
    [../]
  [../]
  # [./flux]
  #   type = CahnHilliardFluxBC
  #   variable = w
  #   boundary = 'top bottom left right'
  #   flux = '1 -1 0 0'
  #   mob_name = D
  #   args = 'c'
  # [../]
   [./bottom_y]
     type = DirichletBC
     variable = disp_y
     boundary = 'bottom'
     value = 0
   [../]
   [./top_y]
     type = DirichletBC
     variable = disp_y
     boundary = 'top'
     # prescribed displacement 
     # -5 will result in a compressive stress
     #  5 will result in a tensile stress
    #  value = -3
     value = -1
   [../]
 #   [./left_x]
 #     type = DirichletBC
 #     variable = disp_x
 #     boundary = 'left'
 #     value = 0
 #   [../]

  # [./right_x]
  #   type = DirichletBC
  #   variable = disp_x
  #   boundary = 'right'
  #   value = 8
  # [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = 0.01
  [../]
[]

[Materials]
  [./chemical_free_energy]
    type = SinteringFreeEnergy
    block = 0
    c = c
    v = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8'
    f_name = Fc
    derivative_order = 2
    #outputs = console
  [../]
  [./CH_mat]
    type = PFDiffusionGrowth
    block = 0
    rho = c
    v = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8'
    outputs = console
  [../]
  [./constant_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = '  A    B   L   kappa_op kappa_c'
    prop_values = '16.0 1.0 1.0  5.0      10.0    '
   # 16.0 1.0 1.0 0.5 1.0
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 0.000000001
  [../]
  #   [./var_dependence]
  #     type = DerivativeParsedMaterial
  #     block = 0
  #     # eigenstrain coefficient
  #     # -0.1 will result in an undersized precipitate
  #     #  0.1 will result in an oversized precipitate
  #     function = 0.1*c
  #     args = c
  #     f_name = var_dep
  #     enable_jit = true
  #     derivative_order = 2
  #   [../]
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
    [./var_dependence]
    type = DerivativeParsedMaterial
    block = 0
    function = 0.2*c
    args = c
    f_name = var_dep
    enable_jit = true
    derivative_order = 2
  [../]
  [./eigenstrain]
    type = ComputeVariableEigenstrain
    block = 0
    eigen_base = '1 1 1 0 0 0'
    prefactor = var_dep
    #outputs = exodus
    args = 'c'
    eigenstrain_name = eigenstrain
  [../]
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
  # [./run_time]
  #   type = RunTime
  #   time_type = active
  # [../]
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
  [./grain_size_gr2]
    type = ElementIntegralVariablePostprocessor
    variable = gr2
  [../]
  [./gb_area]
    type = GrainBoundaryArea
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    coupled_groups = 'c,w c,gr0,gr1,gr2,gr3,gr4,gr5,gr6,gr7,gr8 '
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
  l_max_its = 20
  nl_max_its = 20
  nl_abs_tol = 1e-08
  nl_rel_tol = 1e-06
  l_tol = 1e-04
  end_time = 20
  #dt = 0.01
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.001
    growth_factor = 1.5
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
