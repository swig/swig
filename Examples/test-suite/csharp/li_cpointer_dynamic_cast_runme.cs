using System;
using li_cpointer_dynamic_castNamespace;

public class runme
{
  public static void swig_assert(bool b, string msg) {
    if (!b)
      throw new Exception(msg);
  }
  static void Main()
  {
    // Get a Derived object using a Base pointer;
    Base base_point_derived = Derived.NewDerived();
    swig_assert(base_point_derived.val1() == 11, "base_point_derived fail calling Derived::val1()");
    swig_assert(base_point_derived.val2() == 2, "base_point_derived fail calling Base::val2()");
    // Dynamic cast to original Derived class;
    Derived derived_dyn = li_cpointer_dynamic_cast.dynDerivedCast(base_point_derived);
    swig_assert(derived_dyn != null, "dynamic cast to derived_dyn fail");
    swig_assert(derived_dyn.val1() == 11, "derived_dyn fail calling Derived::val1()");
    swig_assert(derived_dyn.val2() == 12, "derived_dyn fail calling Derived::val2()");
    // Static cast work the same as dynamic cast, when used with the derived class!;
    Derived derived_static = li_cpointer_dynamic_cast.staticDerivedCast(base_point_derived);
    swig_assert(derived_static != null, "static cast to derived_static fail");
    swig_assert(derived_static.val1() == 11, "derived_static fail calling Derived::val1()");
    swig_assert(derived_static.val2() == 12, "derived_static fail calling Derived::val2()");

    // Get an Other object using a Base pointer;
    Base base_point_other = Other.NewOther();
    swig_assert(base_point_other.val1() == 21, "base_point_other fail calling Other::val1()");
    swig_assert(base_point_other.val2() == 2, "base_point_other fail calling Base::val2()");
    // Dynamic cast to original Other class;
    Other other_dyn = li_cpointer_dynamic_cast.dynOtherCast(base_point_other);
    swig_assert(other_dyn != null, "dynamic cast to other_dyn fail");
    swig_assert(other_dyn.val1() == 21, "other_dyn fail calling Other::val1()");
    swig_assert(other_dyn.val2() == 22, "other_dyn fail calling Other::val2()");
    // Static cast work the same as dynamic cast, when used with the other class!;
    Other other_static = li_cpointer_dynamic_cast.staticOtherCast(base_point_other);
    swig_assert(other_static != null, "static cast to other_static fail");
    swig_assert(other_static.val1() == 21, "other_static fail calling Other::val1()");
    swig_assert(other_static.val2() == 22, "other_static fail calling Other::val2()");

    // Get a Base object;
    Base baseObj = new Base();
    swig_assert(baseObj.val1() == 1, "base fail calling Base::val1()");
    swig_assert(baseObj.val2() == 2, "base fail calling Base::val2()");

    // Dynamic cast gives NULL as expected;
    swig_assert(li_cpointer_dynamic_cast.dynOtherCast(base_point_derived) == null, "'Derived' object can not cast to 'Other'");
    swig_assert(li_cpointer_dynamic_cast.dynDerivedCast(base_point_other) == null, "'Other' object can not cast to 'Derived'");
    swig_assert(li_cpointer_dynamic_cast.dynOtherCast(baseObj) == null, "'Base' object can not cast to 'Other'");
    swig_assert(li_cpointer_dynamic_cast.dynDerivedCast(baseObj) == null, "'Base' object can not cast to 'Derived'");

    // Static cast gives a hybrid result;
    // The virtual method point to original object class, as we expect!;
    // While the non-virtual method uses the new pointed class method!;
    Other non_cpp_other_derived = li_cpointer_dynamic_cast.staticOtherCast(base_point_derived);
    swig_assert(non_cpp_other_derived != null, "static cast to non_cpp_other_derived fail");
    swig_assert(non_cpp_other_derived.val1() == 11, "non_cpp_other_derived fail calling Derived::val1()");
    swig_assert(non_cpp_other_derived.val2() == 22, "non_cpp_other_derived fail calling Other::val2()");
    Derived non_cpp_derived_other = li_cpointer_dynamic_cast.staticDerivedCast(base_point_other);
    swig_assert(non_cpp_derived_other != null, "static cast to non_cpp_derived_other fail");
    swig_assert(non_cpp_derived_other.val1() == 21, "non_cpp_derived_other fail calling Other::val1()");
    swig_assert(non_cpp_derived_other.val2() == 12, "non_cpp_derived_other fail calling Derived::val2()");
    Derived non_cpp_base_derived = li_cpointer_dynamic_cast.staticDerivedCast(baseObj);
    swig_assert(non_cpp_base_derived != null, "static cast to non_cpp_base_derived fail");
    swig_assert(non_cpp_base_derived.val1() == 1, "non_cpp_base_derived fail calling Base::val1()");
    swig_assert(non_cpp_base_derived.val2() == 12, "non_cpp_base_derived fail calling Derived::val2()");
    Other non_cpp_base_other = li_cpointer_dynamic_cast.staticOtherCast(baseObj);
    swig_assert(non_cpp_base_other != null, "static cast to non_cpp_base_other fail");
    swig_assert(non_cpp_base_other.val1() == 1, "non_cpp_base_other fail calling Base::val1()");
    swig_assert(non_cpp_base_other.val2() == 22, "non_cpp_base_other fail calling Other::val2()");
  }
}
