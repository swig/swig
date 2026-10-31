#include "global_vars/global_vars_wrap.h"
#include <assert.h>

using namespace global_vars;

int main(int argc, const char *argv[]) {
  A an;
  an.x(42);
  assign_ap(&an);
  A *p = ap();
  assert(p->x() == 42);
  delete p;
  avp(&an);
  p = avp();
  assert(p->x() == 42);
  delete p;

  A *global_a = a();
  global_a->x(7);
  delete global_a;
  A *cp = acp();
  assert(cp->x() == 7);
  delete cp;
  A *cvp = acvp();
  assert(cvp->x() == 7);
  delete cvp;
  A *cpr = acpr();
  assert(cpr->x() == 7);
  delete cpr;

  h(Hola);
  assert(*hcp() == Hola);
  assert(*hcpr() == Hola);
  assign_hp(hcpr());
  assert(hp() == hcp());
  return 0;
}
