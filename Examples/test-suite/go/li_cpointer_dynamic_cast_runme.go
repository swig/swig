package main

import "swigtests/li_cpointer_dynamic_cast"

func swig_assert(b bool, msg string) {
    if !b {
        panic(msg)
    }
}
func main() {
    // Get a Derived object using a Base pointer
    base_point_derived := li_cpointer_dynamic_cast.DerivedNewDerived()
    defer li_cpointer_dynamic_cast.DeleteBase(base_point_derived)
    swig_assert(base_point_derived.Val1() == 11, "base_point_derived fail calling Derived::val1()")
    swig_assert(base_point_derived.Val2() == 2, "base_point_derived fail calling Base::val2()")
    // Dynamic cast to original Derived class
    derived_dyn := li_cpointer_dynamic_cast.DynDerivedCast(base_point_derived)
    swig_assert(derived_dyn.Swigcptr() != 0, "dynamic cast to derived_dyn fail")
    swig_assert(derived_dyn.Val1() == 11, "derived_dyn fail calling Derived::val1()")
    swig_assert(derived_dyn.Val2() == 12, "derived_dyn fail calling Derived::val2()")
    // Static cast work the same as dynamic cast, when used with the derived class!
    derived_static := li_cpointer_dynamic_cast.StaticDerivedCast(base_point_derived)
    swig_assert(derived_static.Swigcptr() != 0, "static cast to derived_static fail")
    swig_assert(derived_static.Val1() == 11, "derived_static fail calling Derived::val1()")
    swig_assert(derived_static.Val2() == 12, "derived_static fail calling Derived::val2()")

    // Get an Other object using a Base pointer
    base_point_other := li_cpointer_dynamic_cast.OtherNewOther()
    defer li_cpointer_dynamic_cast.DeleteBase(base_point_other)
    swig_assert(base_point_other.Val1() == 21, "base_point_other fail calling Other::val1()")
    swig_assert(base_point_other.Val2() == 2, "base_point_other fail calling Base::val2()")
    // Dynamic cast to original Other class
    other_dyn := li_cpointer_dynamic_cast.DynOtherCast(base_point_other)
    swig_assert(other_dyn.Swigcptr() != 0, "dynamic cast to other_dyn fail")
    swig_assert(other_dyn.Val1() == 21, "other_dyn fail calling Other::val1()")
    swig_assert(other_dyn.Val2() == 22, "other_dyn fail calling Other::val2()")
    // Static cast work the same as dynamic cast, when used with the other class!
    other_static := li_cpointer_dynamic_cast.StaticOtherCast(base_point_other)
    swig_assert(other_static.Swigcptr() != 0, "static cast to other_static fail")
    swig_assert(other_static.Val1() == 21, "other_static fail calling Other::val1()")
    swig_assert(other_static.Val2() == 22, "other_static fail calling Other::val2()")

    // Get a Base object
    base := li_cpointer_dynamic_cast.NewBase()
    defer li_cpointer_dynamic_cast.DeleteBase(base)
    swig_assert(base.Val1() == 1, "base fail calling Base::val1()")
    swig_assert(base.Val2() == 2, "base fail calling Base::val2()")

    // Dynamic cast gives NULL as expected
    swig_assert(li_cpointer_dynamic_cast.DynOtherCast(base_point_derived).Swigcptr() == 0, "'Derived' object can not cast to 'Other'")
    swig_assert(li_cpointer_dynamic_cast.DynDerivedCast(base_point_other).Swigcptr() == 0, "'Other' object can not cast to 'Derived'")
    swig_assert(li_cpointer_dynamic_cast.DynOtherCast(base).Swigcptr() == 0, "'Base' object can not cast to 'Other'")
    swig_assert(li_cpointer_dynamic_cast.DynDerivedCast(base).Swigcptr() == 0, "'Base' object can not cast to 'Derived'")

    // Static cast gives a hybrid result
    // The virtual method point to original object class, as we expect!
    // While the non-virtual method uses the new pointed class method!
    non_cpp_other_derived := li_cpointer_dynamic_cast.StaticOtherCast(base_point_derived)
    swig_assert(non_cpp_other_derived.Swigcptr() != 0, "static cast to non_cpp_other_derived fail")
    swig_assert(non_cpp_other_derived.Val1() == 11, "non_cpp_other_derived fail calling Derived::val1()")
    swig_assert(non_cpp_other_derived.Val2() == 22, "non_cpp_other_derived fail calling Other::val2()")
    non_cpp_derived_other := li_cpointer_dynamic_cast.StaticDerivedCast(base_point_other)
    swig_assert(non_cpp_derived_other.Swigcptr() != 0, "static cast to non_cpp_derived_other fail")
    swig_assert(non_cpp_derived_other.Val1() == 21, "non_cpp_derived_other fail calling Other::val1()")
    swig_assert(non_cpp_derived_other.Val2() == 12, "non_cpp_derived_other fail calling Derived::val2()")
    non_cpp_base_derived := li_cpointer_dynamic_cast.StaticDerivedCast(base)
    swig_assert(non_cpp_base_derived.Swigcptr() != 0, "static cast to non_cpp_base_derived fail")
    swig_assert(non_cpp_base_derived.Val1() == 1, "non_cpp_base_derived fail calling Base::val1()")
    swig_assert(non_cpp_base_derived.Val2() == 12, "non_cpp_base_derived fail calling Derived::val2()")
    non_cpp_base_other := li_cpointer_dynamic_cast.StaticOtherCast(base)
    swig_assert(non_cpp_base_other.Swigcptr() != 0, "static cast to non_cpp_base_other fail")
    swig_assert(non_cpp_base_other.Val1() == 1, "non_cpp_base_other fail calling Base::val1()")
    swig_assert(non_cpp_base_other.Val2() == 22, "non_cpp_base_other fail calling Other::val2()")
}
