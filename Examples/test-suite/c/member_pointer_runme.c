#include "member_pointer/member_pointer_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
  SWIGTYPE_m_Shape__f_void__double area_pt = member_pointer_areapt();
  SWIGTYPE_m_Shape__f_void__double perim_pt = member_pointer_perimeterpt();
  member_pointer_Square *square = member_pointer_Square_new(10);
  member_pointer_Shape *s = (member_pointer_Shape *)square;

  assert(member_pointer_do_op(s, area_pt) == 100.0);
  assert(member_pointer_do_op(s, perim_pt) == 40.0);

  // Variables
  assert(member_pointer_do_op(s, member_pointer_areavar_get()) == 100.0);
  assert(member_pointer_do_op(s, member_pointer_perimetervar_get()) == 40.0);
  member_pointer_areavar_set(perim_pt);
  assert(member_pointer_do_op(s, member_pointer_areavar_get()) == 40.0);

  // Typedefs and const references
  assert(member_pointer_do_op_td(s, perim_pt) == 40.0);
  assert(member_pointer_do_op(s, member_pointer_perimeterpt_td()) == 40.0);
  assert(member_pointer_do_op_cref(s, area_pt) == 100.0);
  assert(member_pointer_do_op(s, member_pointer_perimetervar_td_cref()) == 40.0);

  // Member functions returning a value, a pointer and a reference
  assert(member_pointer_call1(member_pointer_addbyvaluept(), 1, 2) == 3);
  assert(member_pointer_call2(member_pointer_addbypointerpt(), 3, 4) == 7);

  // Constants
  assert(member_pointer_do_op(s, member_pointer_AREAPT_get()) == 100.0);
  assert(member_pointer_do_op(s, member_pointer_PERIMPT_get()) == 40.0);
  assert(member_pointer_is_null_memberpt(member_pointer_NULLPT_get()));
  assert(member_pointer_call1(member_pointer_ADD_BY_VALUE_get(), 1, 2) == 3);
  assert(member_pointer_call2(member_pointer_ADD_BY_POINTER_get(), 3, 4) == 7);
  assert(member_pointer_call3(member_pointer_ADD_BY_REFERENCE_get(), 5, 6) == 11);

  // Overloaded on the member pointer type
  assert(member_pointer_call_overloaded_mFunktionsf_rci_ii_i_i(member_pointer_addbyvaluept(), 1, 2) == 3);
  assert(member_pointer_call_overloaded_mFunktionsf_rci_ipi_i_i(member_pointer_addbypointerpt(), 3, 4) == -7);
  assert(member_pointer_call_overloaded_i_i_i(10, 5, 6) == 110);

  // Overloaded on a member pointer and a pointer
  member_pointer_Funktions *f = member_pointer_Funktions_new();
  assert(member_pointer_memberpt_or_pointer_mFunktionsf_rci_ii(member_pointer_addbyvaluept()) == 3);
  assert(member_pointer_memberpt_or_pointer_pFunktions(f) == 10);
  assert(member_pointer_memberpt_or_pointer_pFunktions(0) == 20);
  member_pointer_Funktions_delete(f);

  // NULL member pointers
  assert(member_pointer_is_null_memberpt(member_pointer_get_null_memberpt()));
  assert(!member_pointer_is_null_memberpt(area_pt));

  member_pointer_Square_delete(square);
  return 0;
}
