#include "ACParticleGrowthAniso.h"
// #include "AnisoGBEnergyUserObject.h"

registerMooseObject("CrowApp", ACParticleGrowthAniso);

template <> InputParameters validParams<ACParticleGrowthAniso>() {
  InputParameters params = ACBulk<Real>::validParams();
  params.addRequiredCoupledVarWithAutoBuild("v", "var_name_base", "op_num",
                                            "Array of coupled variables");
  params.addRequiredCoupledVar("c", "phase field variable, particle density");
  params.addParam<Real>(
      "int_width", "The interfacial width in the lengthscale of the problem");
  params.addParam<Real>("length_scale", 1.0e-9,
                        "Length scale in m, where default is 1 nm");
  params.addRequiredParam<unsigned int>(
      "op", "The order parameter number this is acting on");
  // params.addRequiredParam<UserObjectName>(
  //     "gbenergymap", "Where the map of the energies are held");
  return params;
}

ACParticleGrowthAniso::ACParticleGrowthAniso(const InputParameters &parameters)
    : ACBulk<Real>(parameters), _c(coupledValue("c")), _c_var(coupled("c")),
      _op(getParam<unsigned int>("op")), _op_num(coupledComponents("v")),
      _vals(_op_num), _grad_vals(_op_num), _vals_var(_op_num),
      // _aniso_GB_energy(getUserObject<AnisoGBEnergyUserObject>("gbenergymap")),
      _length_scale(getParam<Real>("length_scale")),
      _int_width(getParam<Real>("int_width")),
      _ncrys(coupledComponents("v")) // determine number of grains from the
                                     // number of names passed in.  Note this is
                                     // the actual number -1
{
  // Loop through grains and load coupled variables into the arrays
  for (unsigned int i = 0; i < _ncrys; ++i) {
    _vals[i] = &coupledValue("v", i);
    _grad_vals[i] = &coupledGradient("v", i);
    _vals_var[i] = coupled("v", i);
  }
}

Real ACParticleGrowthAniso::computeDFDOP(PFFunctionType type) {
  // start sums at zero
  Real SumEtaj = 0.0;
  Real SumEtaij = 0.0;
  Real SumEtaSigmaj = 0.0;
  Real SumEtaSigmaij = 0.0;
  Real SumEtaj3 = 0.0;
  Real SumGradEta = 0.0;
  Real Dsigma_Deta = 0.0;
  Real D2sigma_Deta2 = 0.0;

  // const AnisoGBEnergyUserObject::SigmaIJMap &gb_energy_map =
  //     _aniso_GB_energy.getGBEnergies(_current_elem->id());
  // if (gb_energy_map.size() >= 2) {
  //   std::set<unsigned int> op_set;
  //   for (AnisoGBEnergyUserObject::SigmaIJMap::const_iterator it =
  //            gb_energy_map.begin();
  //        it != gb_energy_map.end(); ++it) {
  //     unsigned int op1 = (it->first).first;
  //     unsigned int op2 = (it->first).second;
  //     op_set.insert(op1);
  //     op_set.insert(op2);
  //     Real sigmaij = it->second;
  //     SumEtaij += (*_vals[op1])[_qp] * (*_vals[op1])[_qp] *
  //     (*_vals[op2])[_qp] *
  //                 (*_vals[op2])[_qp];
  //     SumEtaSigmaij += sigmaij * (*_vals[op1])[_qp] * (*_vals[op1])[_qp] *
  //                      (*_vals[op2])[_qp] * (*_vals[op2])[_qp];
  //   }
  //   if (op_set.count(_op)) {
  //     for (std::set<unsigned int>::const_iterator it = op_set.begin();
  //          it != op_set.end(); ++it) {
  //       if (*it != _op) {
  //         SumEtaj += (*_vals[*it])[_qp] * (*_vals[*it])[_qp];
  //         SumEtaj3 +=
  //             (*_vals[*it])[_qp] * (*_vals[*it])[_qp] * (*_vals[*it])[_qp];
  //         SumGradEta += ((*_grad_vals[*it])[_qp] * (*_grad_vals[*it])[_qp]);
  //
  //         Real sigmaiop;
  //         // The lower order parameter is first in the pair TODO: check if
  //         stuff
  //         // was found!!!
  //         if (_op > *it)
  //           sigmaiop =
  //               gb_energy_map
  //                   .find(std::pair<unsigned int, unsigned int>(*it, _op))
  //                   ->second;
  //         else
  //           sigmaiop =
  //               gb_energy_map
  //                   .find(std::pair<unsigned int, unsigned int>(_op, *it))
  //                   ->second;
  //
  //         SumEtaSigmaj += sigmaiop * (*_vals[*it])[_qp] * (*_vals[*it])[_qp];
  //       }
  //     }

  Dsigma_Deta = 2.0 * _u[_qp] *
                (SumEtaSigmaj * SumEtaij - SumEtaj * SumEtaSigmaij) /
                (SumEtaij * SumEtaij);
  D2sigma_Deta2 = 2.0 * (SumEtaSigmaj * SumEtaij - SumEtaj * SumEtaSigmaij) /
                  (SumEtaij * SumEtaij);
  const Real JtoeV = 6.24150974e18; // joule to eV conversion
  Dsigma_Deta *= JtoeV * (_length_scale * _length_scale);   // eV/nm^2
  D2sigma_Deta2 *= JtoeV * (_length_scale * _length_scale); // eV/nm^2
  // }
  // }
  // Calcualte either the residual or jacobian of the grain growth free energy
  switch (type) {
  case Residual:
    return -(7.0 / _int_width) * Dsigma_Deta * _c[_qp] * _c[_qp] *
               (1.0 - _c[_qp]) * (1.0 - _c[_qp]) +
           Dsigma_Deta / _int_width *
               (_c[_qp] * _c[_qp] + 6.0 * (1.0 - _c[_qp]) * SumEtaj -
                4.0 * (2.0 - _c[_qp]) * SumEtaj3 + 3.0 * SumEtaj * SumEtaj) +
           0.75 * Dsigma_Deta * _int_width * SumGradEta;

  case Jacobian:
    return _phi[_j][_qp] * (-7.0 / _int_width) * D2sigma_Deta2 * _c[_qp] *
               _c[_qp] * (1.0 - _c[_qp]) * (1.0 - _c[_qp]) +
           _phi[_j][_qp] * D2sigma_Deta2 / _int_width *
               (_c[_qp] * _c[_qp] + 6.0 * (1.0 - _c[_qp]) * SumEtaj -
                4.0 * (2.0 - _c[_qp]) * SumEtaj3 + 3.0 * SumEtaj * SumEtaj) +
           0.75 * _phi[_j][_qp] * D2sigma_Deta2 * _int_width * SumGradEta;
  }
  mooseError("Invalid type passed in");
}

Real ACParticleGrowthAniso::computeQpOffDiagJacobian(unsigned int /*jvar*/) {
  // if (jvar == _c_var)
  // {
  //  Real dDFDc = (-(14.0 / _int_width) * Dsigma_Deta * _c[_qp] * (1.0 - 3.0 *
  //  _c[_qp] + 2.0 * _c[_qp] * _c[_qp])
  //               + Dsigma_Deta / _int_width * (2.0 * _c[_qp] - 6.0 * SumEtaj
  //               + 4.0 * SumEtaj3 )) * _phi[_j][_qp];
  //  return _L[_qp] * _test[_i][_qp] * dDFDc;
  // }
  // for (unsigned int i = 0; i < _ncrys; ++i)
  // if (jvar == _vals_var[i])
  //{
  // Real dSumEtaj = 2.0 * (*_vals[i])[_qp] * _phi[_j][_qp]; //Derivative of
  // SumEtaj  Real dDFDOP =  12.0 * _B[_qp] * _u[_qp] * dSumEtaj;  return
  // _L[_qp] * _test[_i][_qp] * dDFDOP;
  //}

  return 0.0;
}
