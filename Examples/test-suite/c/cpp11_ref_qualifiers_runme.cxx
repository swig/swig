#include "cpp11_ref_qualifiers/cpp11_ref_qualifiers_wrap.h"
#include <assert.h>

using namespace cpp11_ref_qualifiers;

int main(int argc, const char *argv[]) {
  Host h;
  const Host &ch = h;
  h.h1();
  ch.h2();
  ch.h5();
  ch.h6();
  ch.h7();
  h.h();

  FuncPtrHost fh;
  const FuncPtrHost &cfh = fh;
  assert(callIntFunc(fh.p1(), 1) == 2);
  assert(callIntFunc(cfh.p3(), 2) == 3);

  Renames r;
  const Renames &cr = r;
  r.R1();
  cr.S1(0);

  DefaultArgs d;
  const DefaultArgs &cd = d;
  assert(cd.cvref() == 3);
  assert(cd.cvref(10) == 12);
  assert(cd.cvref(10, 20) == 30);

  ConstOverloads cvo;
  const ConstOverloads &ccvo = cvo;
  assert(cvo.cl() == 1);
  assert(ccvo.cl() == 2);
  assert(cvo.cr() == 3);
  assert(ccvo.cr() == 4);
  assert(cvo.cvl() == 5);
  assert(ccvo.cvl() == 6);
  return 0;
}
