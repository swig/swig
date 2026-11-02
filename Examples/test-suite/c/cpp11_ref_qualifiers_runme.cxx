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
  assert(callIntFunc(cfh.p3Renamed(), 2) == 3);

  Renames r;
  const Renames &cr = r;
  r.RR1();
  cr.SS1(0);

  DefaultArgs d;
  const DefaultArgs &cd = d;
  assert(cd.cvref_renamed() == 3);
  assert(cd.cvref_renamed(10) == 12);
  assert(cd.cvref_renamed(10, 20) == 30);

  ConstOverloads cvo;
  const ConstOverloads &ccvo = cvo;
  assert(cvo.cl() == 1);
  assert(ccvo.cl_const() == 2);
  assert(cvo.cr() == 3);
  assert(ccvo.cr_const() == 4);
  assert(cvo.cvl() == 5);
  assert(ccvo.cvl_const_volatile() == 6);

  ConversionOperators co;
  std::string s = co;
  assert(s.empty());
  assert(co.StringConvertMove().empty());
  return 0;
}
