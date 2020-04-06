[Materials]
# Free energy for phase A

[./free_energy_A]
  type = DerivativeParsedMaterial
  block = 0
  f_name = Fa
  args = 'c'
  function = '(c-0.1)^2'
  third_derivatives = false
  enable_jit = true
[../]

# Free energy for phase B

[./free_energy_B]
  type = DerivativeParsedMaterial
  block = 0
  f_name = Fb
  args = 'c'
  function = '(c-0.9)^2'
  third_derivatives = false
  enable_jit = true
[../]

[./switching]
  type = SwitchingFunctionMaterial
  block = 0
  eta = eta
  h_order = SIMPLE
[../]

[./barrier]
  type = BarrierFunctionMaterial
  block = 0
  eta = eta
  g_order = SIMPLE
[../]

# Total free energy F = h(phi)*Fb + (1-h(phi))*Fa

[./free_energy]
  type = DerivativeTwoPhaseMaterial
  block = 0
  f_name = F    # Name of the global free energy function (use this in the Parsed Function Kernels)
  fa_name = Fa  # f_name of the phase A free energy function
  fb_name = Fb  # f_name of the phase B free energy function
  args = 'c'
  eta = eta     # order parameter that switches between A and B phase
  third_derivatives = false
  outputs = exodus
[../]
[]
