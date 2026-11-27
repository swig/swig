#include "member_pointer/member_pointer_wrap.h"
#include <assert.h>

using namespace member_pointer;

int main(int argc, const char *argv[]) {
  SWIGTYPE_m_Shape__f_void__double area_pt = areapt();
  SWIGTYPE_m_Shape__f_void__double perim_pt = perimeterpt();
  Square s(10);

  assert(do_op(&s, area_pt) == 100.0);
  assert(do_op(&s, perim_pt) == 40.0);

  // Variables
  assert(do_op(&s, areavar()) == 100.0);
  areavar(perim_pt);
  assert(do_op(&s, areavar()) == 40.0);

  // Typedefs and const references
  assert(do_op_td(&s, perimeterpt_td()) == 40.0);
  assert(do_op_cref(&s, area_pt) == 100.0);
  assert(do_op(&s, perimetervar_td_cref()) == 40.0);

  // Constants
  assert(do_op(&s, AREAPT()) == 100.0);
  assert(do_op(&s, PERIMPT()) == 40.0);
  assert(is_null_memberpt(NULLPT()));
  assert(call1(ADD_BY_VALUE(), 1, 2) == 3);
  assert(call2(ADD_BY_POINTER(), 3, 4) == 7);
  assert(call3(ADD_BY_REFERENCE(), 5, 6) == 11);

  // Overloaded on the member pointer type
  assert(call_overloaded(addbyvaluept(), 1, 2) == 3);
  assert(call_overloaded(addbypointerpt(), 3, 4) == -7);
  assert(call_overloaded(10, 5, 6) == 110);

  // Overloaded on a member pointer and a pointer
  Funktions f;
  assert(memberpt_or_pointer(addbyvaluept()) == 3);
  assert(memberpt_or_pointer(&f) == 10);
  assert(memberpt_or_pointer(nullptr) == 20);

  // NULL member pointers
  assert(is_null_memberpt(get_null_memberpt()));
  assert(!is_null_memberpt(area_pt));
  return 0;
}
