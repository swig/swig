#include "cpp11_ref_qualifiers/cpp11_ref_qualifiers_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
  cpp11_ref_qualifiers_QualifierOverloads *q = cpp11_ref_qualifiers_QualifierOverloads_new();
  assert(cpp11_ref_qualifiers_QualifierOverloads_r_i(q, 10) == 11);
  assert(cpp11_ref_qualifiers_QualifierOverloads_r_rvalue_i(q, 10) == 12);
  assert(cpp11_ref_qualifiers_QualifierOverloads_rc_i(q, 10) == 13);
  assert(cpp11_ref_qualifiers_QualifierOverloads_rc_const_rvalue_i(q, 10) == 14);
  cpp11_ref_qualifiers_QualifierOverloads_delete(q);

  cpp11_ref_qualifiers_ConstOverloads *cvo = cpp11_ref_qualifiers_ConstOverloads_new();
  assert(cpp11_ref_qualifiers_ConstOverloads_cl(cvo) == 1);
  assert(cpp11_ref_qualifiers_ConstOverloads_cl_const(cvo) == 2);
  assert(cpp11_ref_qualifiers_ConstOverloads_cr(cvo) == 3);
  assert(cpp11_ref_qualifiers_ConstOverloads_cr_const(cvo) == 4);
  assert(cpp11_ref_qualifiers_ConstOverloads_cvl(cvo) == 5);
  assert(cpp11_ref_qualifiers_ConstOverloads_cvl_const_volatile(cvo) == 6);
  cpp11_ref_qualifiers_ConstOverloads_delete(cvo);
  return 0;
}
