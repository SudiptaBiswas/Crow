# This simulation tests the AnisoGBEnergyUserObject and the GBEvolutionAniso material

[Mesh]
  type = GeneratedMesh
  dim = 2 # Problem dimension
  nx = 10 # Number of elements in the x-direction
  nx = 10 # Number of elements in the x-direction
  xmax = 100 # maximum x-coordinate of the mesh
  ymax = 100 # maximum x-coordinate of the mesh
  elem_type = QUAD4 # Type of elements used in the mesh
[]

[GlobalParams]
  # Parameters used by several kernels that are defined globally to simplify input file
  op_num = 2 # Number of order parameters used
  var_name_base = gr # Base name of grains
  grain_num = 2 #Number of grains
[]

[Variables]
  # Variable block, where all variables in the simulation are declared
  [./gr0]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = BoundingBoxIC
      x1 = 50
      x2 = 100
      y1 = 0
      y2 = 0
      inside = 0.0
      outside = 1.0
    [../]
  [../]

  [./gr1]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = BoundingBoxIC
      x1 = 50
      x2 = 100
      y1 = 0
      y2 = 0
      inside = 1.0
      outside = 0.0
    [../]
  [../]
[]

[AuxVariables]
  [./Fbulk]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./Fbulk]
    type = ACBulkFreeEnergy
    variable = Fbulk
    gamma = gamma_asymm
    mu = mu
  [../]
[]

[Kernels]
  # Kernel block, where the kernels defining the residual equations are set up.
  [./Polycrystal5DoFKernel]
    # Custom action creating all necessary kernels for grain growth.  All input parameters are up in GlobalParams
    gbenergymap = anisoenergy
  [../]
[]

[BCs]
  # Boundary Condition block
  [./Periodic]
    [./top_bottom]
      auto_direction = 'x' # Makes problem periodic in the x direction
    [../]
  [../]
[]

[Materials]
  [./CuGrGr]
    # Material properties
    type = GBEvolutionAniso # Quantitative material properties for copper grain growth.  Dimensions are nm and ns
    block = 0 # Block ID (only one block in this problem)
    GBmob0 = 2.5e-6 # Mobility prefactor for Cu from Schonfelder1997
    Q = 0.23 # Activation energy for grain growth from Schonfelder 1997
    T = 450 # K, Constant temperature of the simulation (for mobility calculation)
    wGB = 14 # nm, Width of the diffuse GB
    gbenergymap = anisoenergy
    outputs = exodus
  [../]
[]

[UserObjects]
  [./grain_tracker]
    type = GrainTracker
    threshold = 0.2
    use_single_map = false
    enable_var_coloring = true
    condense_map_info = true
    connecting_threshold = 0.08
    flood_entity_type = elemental
    compute_var_to_feature_map = true
    execute_on = 'initial timestep_begin'
    tracking_step = 0
    outputs = none
  [../]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = 100Tilt.tex
  [../]
  [./anisoenergy]
    type = AnisoGBEnergyUserObject
    euler_angle_provider = euler_angle_file
    grain_tracker = grain_tracker
    execute_on = 'nonlinear linear'
    gb_energy_isotropic = 0.708
    material = Cu
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2 # Type of time integration (2nd order backward euler), defaults to 1st order backward euler

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'

  l_max_its = 30 # Max number of linear iterations
  l_tol = 1e-4 # Relative tolerance for linear solves
  nl_max_its = 40 # Max number of nonlinear iterations
  nl_abs_tol = 1e-11 # Relative tolerance for nonlinear solves
  nl_rel_tol = 1e-10 # Absolute tolerance for nonlinear solves
  start_time = 0.0
  num_steps = 100.0
[]

[Outputs]
  exodus = true
[]
