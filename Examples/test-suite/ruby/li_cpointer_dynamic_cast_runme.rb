#!/usr/bin/env ruby

require 'swig_assert'
require 'li_cpointer_dynamic_cast'

# Get a Derived object using a Base pointer
base_point_derived = Li_cpointer_dynamic_cast::Derived.NewDerived()
swig_assert_equal(base_point_derived.val1(), 11, binding, "base_point_derived fail calling Derived::val1()")
swig_assert_equal(base_point_derived.val2(), 2, binding, "base_point_derived fail calling Base::val2()")
# Dynamic cast to original Derived class
derived_dyn = Li_cpointer_dynamic_cast::dynDerivedCast(base_point_derived)
swig_assert(derived_dyn != nil, binding, "dynamic cast to derived_dyn fail")
swig_assert_equal(derived_dyn.val1(), 11, binding, "derived_dyn fail calling Derived::val1()")
swig_assert_equal(derived_dyn.val2(), 12, binding, "derived_dyn fail calling Derived::val2()")
# Static cast work the same as dynamic cast, when used with the derived class!
derived_static = Li_cpointer_dynamic_cast::staticDerivedCast(base_point_derived)
swig_assert(derived_static != nil, binding, "static cast to derived_static fail")
swig_assert_equal(derived_static.val1(), 11, binding, "derived_static fail calling Derived::val1()")
swig_assert_equal(derived_static.val2(), 12, binding, "derived_static fail calling Derived::val2()")

# Get an Other object using a Base pointer
base_point_other = Li_cpointer_dynamic_cast::Other.NewOther()
swig_assert_equal(base_point_other.val1(), 21, binding, "base_point_other fail calling Other::val1()")
swig_assert_equal(base_point_other.val2(), 2, binding, "base_point_other fail calling Base::val2()")
# Dynamic cast to original Other class
other_dyn = Li_cpointer_dynamic_cast::dynOtherCast(base_point_other)
swig_assert(other_dyn != nil, binding, "dynamic cast to other_dyn fail")
swig_assert_equal(other_dyn.val1(), 21, binding, "other_dyn fail calling Other::val1()")
swig_assert_equal(other_dyn.val2(), 22, binding, "other_dyn fail calling Other::val2()")
# Static cast work the same as dynamic cast, when used with the other class!
other_static = Li_cpointer_dynamic_cast::staticOtherCast(base_point_other)
swig_assert(other_static != nil, binding, "static cast to other_static fail")
swig_assert_equal(other_static.val1(), 21, binding, "other_static fail calling Other::val1()")
swig_assert_equal(other_static.val2(), 22, binding, "other_static fail calling Other::val2()")

# Get a Base object
base = Li_cpointer_dynamic_cast::Base.new
swig_assert_equal(base.val1(), 1, binding, "base fail calling Base::val1()")
swig_assert_equal(base.val2(), 2, binding, "base fail calling Base::val2()")

# Dynamic cast gives NULL as expected
swig_assert_equal(Li_cpointer_dynamic_cast::dynOtherCast(base_point_derived), nil, binding, "'Derived' object can not cast to 'Other'")
swig_assert_equal(Li_cpointer_dynamic_cast::dynDerivedCast(base_point_other), nil, binding, "'Other' object can not cast to 'Derived'")
swig_assert_equal(Li_cpointer_dynamic_cast::dynOtherCast(base), nil, binding, "'Base' object can not cast to 'Other'")
swig_assert_equal(Li_cpointer_dynamic_cast::dynDerivedCast(base), nil, binding, "'Base' object can not cast to 'Derived'")

# Static cast gives a hybrid result
# The virtual method point to original object class, as we expect!
# While the non-virtual method uses the new pointed class method!
non_cpp_other_derived = Li_cpointer_dynamic_cast::staticOtherCast(base_point_derived)
swig_assert(non_cpp_other_derived != nil, binding, "static cast to non_cpp_other_derived fail")
swig_assert_equal(non_cpp_other_derived.val1(), 11, binding, "non_cpp_other_derived fail calling Derived::val1()")
swig_assert_equal(non_cpp_other_derived.val2(), 22, binding, "non_cpp_other_derived fail calling Other::val2()")
non_cpp_derived_other = Li_cpointer_dynamic_cast::staticDerivedCast(base_point_other)
swig_assert(non_cpp_derived_other != nil, binding, "static cast to non_cpp_derived_other fail")
swig_assert_equal(non_cpp_derived_other.val1(), 21, binding, "non_cpp_derived_other fail calling Other::val1()")
swig_assert_equal(non_cpp_derived_other.val2(), 12, binding, "non_cpp_derived_other fail calling Derived::val2()")
non_cpp_base_derived = Li_cpointer_dynamic_cast::staticDerivedCast(base)
swig_assert(non_cpp_base_derived != nil, binding, "static cast to non_cpp_base_derived fail")
swig_assert_equal(non_cpp_base_derived.val1(), 1, binding, "non_cpp_base_derived fail calling Base::val1()")
swig_assert_equal(non_cpp_base_derived.val2(), 12, binding, "non_cpp_base_derived fail calling Derived::val2()")
non_cpp_base_other = Li_cpointer_dynamic_cast::staticOtherCast(base)
swig_assert(non_cpp_base_other != nil, binding, "static cast to non_cpp_base_other fail")
swig_assert_equal(non_cpp_base_other.val1(), 1, binding, "non_cpp_base_other fail calling Base::val1()")
swig_assert_equal(non_cpp_base_other.val2(), 22, binding, "non_cpp_base_other fail calling Other::val2()")
