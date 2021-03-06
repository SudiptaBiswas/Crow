[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 512
  ny = 64
  xmax = 512
  ymax = 64
  elem_type = QUAD4
[]

[Variables]
  [./c]
    order = THIRD
    family = HERMITE
    block = 0
  [../]
[]

[AuxVariables]
  [./T]
    block = 0
  [../]
[]

[Kernels]
  [./CH_temp]
    type = CHParsed
    variable = c
    f_name = F
    args = 'c T'
  [../]
  [./CH_int]
    type = CHInterface
    variable = c
    mob_name = M
    kappa_name = kappa_c
    grad_mob_name = grad_M
    block = 0
  [../]
  [./c_dot]
    type = TimeDerivative
    variable = c
    block = 0
  [../]
[]

[AuxKernels]
  [./temp]
    type = FunctionAux
    variable = T
    function = 470+0.15*x
    block = 0
  [../]
[]

[BCs]
  [./Periodic]
    [./periodic]
      variable = c
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]
  [./mobility]
    type = PFTempMobility
    block = 0
    c = c
    R = 8.314
    T = 470.0
  [../]
  [./F_temp]
    type = DerivativeParsedMaterial
    block = 0
    constant_expressions = '8.314  9.6'
    function = R*T*(c*log(c)+(1-c)*log(1-c))+L*c*(1-c)
    args = 'c T'
    constant_names = 'R L'
    tol_values = 0.001
    tol_names = c
  [../]
[]

[Postprocessors]
  [./c_avg]
    type = ElementAverageValue
    variable = c
    block = 0
  [../]
  [./nodalVar_vol]
    type = NodalVolumeFraction
    variable = c
    mesh_volume = volume
  [../]
  [./Temp]
    type = NodalVolumeFraction
    variable = c
    mesh_volume = c_avg
  [../]
  [./volume]
    type = InternalVolume
  [../]
[]

[Executioner]
  type = Transient
  dt = 2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -sub_pc_type'
  petsc_options_value = 'asm lu'
  end_time = 60
[]

[Outputs]
  [./console]
    type = Console
  [../]
  [./exodus]
    type = Exodus
    output_on = 'timestep_end initial'
  [../]
[]

[ICs]
  active = 'Randm'
  [./Randm]
    min = 0.001
    max = 0.999
    variable = c
    type = RandomIC
    block = 0
  [../]
  [./2Particle]
    min = 0.01
    max = 0.02
    op_num = 2
    radius = '9.0 7.0'
    variable = c
    type = TwoParticleDensityIC
  [../]
[]

