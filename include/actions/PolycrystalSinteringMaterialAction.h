#ifndef POLYCRYSTALSINTERINGMATERIALACTION_H
#define POLYCRYSTALSINTERINGMATERIALACTION_H

#include "Action.h"
#include "Material.h"

class PolycrystalSinteringMaterialAction : public Action //, public Material
{
public:
  PolycrystalSinteringMaterialAction(const InputParameters &params);

  virtual void act();

private:
  unsigned int _op_num;
  std::string _var_name_base;
  // VariableName _c;
  bool _implicit;
  bool _disp;
};

template <> InputParameters validParams<PolycrystalSinteringMaterialAction>();

#endif // POLYCRYSTALKERNELACTION_H
