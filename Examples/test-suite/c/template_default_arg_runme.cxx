#include "template_default_arg/template_default_arg_wrap.h"
#include <assert.h>

using namespace template_default_arg;

static int quadruple(int i) {
  return 4 * i;
}

int main(int argc, const char *argv[]) {
  FuncPtrDefault_def fpd;
  FuncPtrParmDefault_int fppd;

  assert(fpd.call(fpd.t(), 4) == 12);
  assert(fppd.call(fpd.t(), 5) == 15);

  fpd.t(quadruple);
  assert(fpd.t() == quadruple);
  assert(fpd.call(quadruple, 4) == 16);

  MemberHolder mh;
  MemberPtrDefault_def mpd;
  MemberFuncPtrDefault_def mfpd;
  assert(mpd.get(mh, mpd.t()) == 5);
  assert(mfpd.call(mh, mfpd.t(), 3) == 8);
  return 0;
}
