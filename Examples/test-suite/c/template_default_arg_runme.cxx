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
  return 0;
}
