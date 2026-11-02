#include "template_default_arg/template_default_arg_wrap.h"
#include <assert.h>

static int quadruple(int i) {
  return 4 * i;
}

int main(int argc, const char *argv[]) {
  template_default_arg_FuncPtrDefault_def *fpd = template_default_arg_FuncPtrDefault_def_new();
  template_default_arg_FuncPtrParmDefault_int *fppd = template_default_arg_FuncPtrParmDefault_int_new();

  assert(template_default_arg_FuncPtrDefault_def_call(fpd, template_default_arg_FuncPtrDefault_def_t_get(fpd), 4) == 12);
  assert(template_default_arg_FuncPtrParmDefault_int_call(fppd, template_default_arg_FuncPtrDefault_def_t_get(fpd), 5) == 15);

  template_default_arg_FuncPtrDefault_def_t_set(fpd, quadruple);
  assert(template_default_arg_FuncPtrDefault_def_t_get(fpd) == quadruple);
  assert(template_default_arg_FuncPtrDefault_def_call(fpd, quadruple, 4) == 16);

  template_default_arg_MemberHolder *mh = template_default_arg_MemberHolder_new();
  template_default_arg_MemberPtrDefault_def *mpd = template_default_arg_MemberPtrDefault_def_new();
  template_default_arg_MemberFuncPtrDefault_def *mfpd = template_default_arg_MemberFuncPtrDefault_def_new();
  assert(template_default_arg_MemberPtrDefault_def_get(mpd, mh, template_default_arg_MemberPtrDefault_def_t_get(mpd)) == 5);
  assert(template_default_arg_MemberFuncPtrDefault_def_call(mfpd, mh, template_default_arg_MemberFuncPtrDefault_def_t_get(mfpd), 3) == 8);

  template_default_arg_MemberFuncPtrDefault_def_delete(mfpd);
  template_default_arg_MemberPtrDefault_def_delete(mpd);
  template_default_arg_MemberHolder_delete(mh);
  template_default_arg_FuncPtrParmDefault_int_delete(fppd);
  template_default_arg_FuncPtrDefault_def_delete(fpd);
  return 0;
}
