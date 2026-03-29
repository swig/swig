#include <stdio.h>
#include <stdlib.h>

#include "li_cpointer_dynamic_cast/li_cpointer_dynamic_cast_wrap.h"

static void check(int ok, const char *test) {
  if (!ok) {
    fprintf(stderr, "Test %s failed\n", test);
    exit(1);
  }
}

int main() {
  /* Get a Derived object using a Base pointer; */
  li_cpointer_dynamic_cast_Base* base_point_derived = li_cpointer_dynamic_cast_Derived_NewDerived();
  check(li_cpointer_dynamic_cast_Base_val1(base_point_derived) == 11, "base_point_derived fail calling Derived::val1()");
  check(li_cpointer_dynamic_cast_Base_val2(base_point_derived) == 2, "base_point_derived fail calling Base::val2()");
  /* Dynamic cast to original Derived class */
  li_cpointer_dynamic_cast_Derived* derived_dyn = li_cpointer_dynamic_cast_dynDerivedCast(base_point_derived);
  check(derived_dyn != NULL, "dynamic cast to derived_dyn fail");
  check(li_cpointer_dynamic_cast_Derived_val1(derived_dyn) == 11, "derived_dyn fail calling Derived::val1()");
  check(li_cpointer_dynamic_cast_Derived_val2(derived_dyn) == 12, "derived_dyn fail calling Derived::val2()");
  /* Static cast work the same as dynamic cast, when used with the derived class! */
  li_cpointer_dynamic_cast_Derived* derived_static = li_cpointer_dynamic_cast_staticDerivedCast(base_point_derived);
  check(derived_static != NULL, "static cast to derived_static fail");
  check(li_cpointer_dynamic_cast_Derived_val1(derived_static) == 11, "derived_static fail calling Derived::val1()");
  check(li_cpointer_dynamic_cast_Derived_val2(derived_static) == 12, "derived_static fail calling Derived::val2()");

  /* Get an Other object using a Base pointer */
  li_cpointer_dynamic_cast_Base* base_point_other = li_cpointer_dynamic_cast_Other_NewOther();
  check(li_cpointer_dynamic_cast_Base_val1(base_point_other) == 21, "base_point_other fail calling Other::val1()");
  check(li_cpointer_dynamic_cast_Base_val2(base_point_other) == 2, "base_point_other fail calling Base::val2()");
  /* Dynamic cast to original Other class */
  li_cpointer_dynamic_cast_Other* other_dyn = li_cpointer_dynamic_cast_dynOtherCast(base_point_other);
  check(other_dyn != NULL, "dynamic cast to other_dyn fail");
  check(li_cpointer_dynamic_cast_Other_val1(other_dyn) == 21, "other_dyn fail calling Other::val1()");
  check(li_cpointer_dynamic_cast_Other_val2(other_dyn) == 22, "other_dyn fail calling Other::val2()");
  /* Static cast work the same as dynamic cast, when used with the other class! */
  li_cpointer_dynamic_cast_Other* other_static = li_cpointer_dynamic_cast_staticOtherCast(base_point_other);
  check(other_static != NULL, "static cast to other_static fail");
  check(li_cpointer_dynamic_cast_Other_val1(other_static) == 21, "other_static fail calling Other::val1()");
  check(li_cpointer_dynamic_cast_Other_val2(other_static) == 22, "other_static fail calling Other::val2()");

  /* Get a Base object */
  li_cpointer_dynamic_cast_Base* base = li_cpointer_dynamic_cast_Base_new();
  check(li_cpointer_dynamic_cast_Base_val1(base) == 1, "base fail calling Base::val1()");
  check(li_cpointer_dynamic_cast_Base_val2(base) == 2, "base fail calling Base::val2()");

  /* Dynamic cast gives NULL as expected */
  check(li_cpointer_dynamic_cast_dynOtherCast(base_point_derived) == NULL, "'Derived' object can not cast to 'Other'");
  check(li_cpointer_dynamic_cast_dynDerivedCast(base_point_other) == NULL, "'Other' object can not cast to 'Derived'");
  check(li_cpointer_dynamic_cast_dynOtherCast(base) == NULL, "'Base' object can not cast to 'Other'");
  check(li_cpointer_dynamic_cast_dynDerivedCast(base) == NULL, "'Base' object can not cast to 'Derived'");
  /*
   * Static cast gives a hybrid result
   * The virtual method point to original object class, as we expect!
   * While the non-virtual method uses the new pointed class method!
   */
  li_cpointer_dynamic_cast_Other* non_cpp_other_derived = li_cpointer_dynamic_cast_staticOtherCast(base_point_derived);
  check(non_cpp_other_derived != NULL, "static cast to non_cpp_other_derived fail");
  check(li_cpointer_dynamic_cast_Other_val1(non_cpp_other_derived) == 11, "non_cpp_other_derived fail calling Derived::val1()");
  check(li_cpointer_dynamic_cast_Other_val2(non_cpp_other_derived) == 22, "non_cpp_other_derived fail calling Other::val2()");
  li_cpointer_dynamic_cast_Derived* non_cpp_derived_other = li_cpointer_dynamic_cast_staticDerivedCast(base_point_other);
  check(non_cpp_derived_other != NULL, "static cast to non_cpp_derived_other fail");
  check(li_cpointer_dynamic_cast_Derived_val1(non_cpp_derived_other) == 21, "non_cpp_derived_other fail calling Other::val1()");
  check(li_cpointer_dynamic_cast_Derived_val2(non_cpp_derived_other) == 12, "non_cpp_derived_other fail calling Derived::val2()");
  li_cpointer_dynamic_cast_Derived* non_cpp_base_derived = li_cpointer_dynamic_cast_staticDerivedCast(base);
  check(non_cpp_base_derived != NULL, "static cast to non_cpp_base_derived fail");
  check(li_cpointer_dynamic_cast_Derived_val1(non_cpp_base_derived) == 1, "non_cpp_base_derived fail calling Base::val1()");
  check(li_cpointer_dynamic_cast_Derived_val2(non_cpp_base_derived) == 12, "non_cpp_base_derived fail calling Derived::val2()");
  li_cpointer_dynamic_cast_Other* non_cpp_base_other = li_cpointer_dynamic_cast_staticOtherCast(base);
  check(non_cpp_base_other != NULL, "static cast to non_cpp_base_other fail");
  check(li_cpointer_dynamic_cast_Other_val1(non_cpp_base_other) == 1, "non_cpp_base_other fail calling Base::val1()");
  check(li_cpointer_dynamic_cast_Other_val2(non_cpp_base_other) == 22, "non_cpp_base_other fail calling Other::val2()");

  return 0;
}
