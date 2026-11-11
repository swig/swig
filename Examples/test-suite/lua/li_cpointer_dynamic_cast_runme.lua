local v=require("li_cpointer_dynamic_cast")

-- Get a Derived object using a Base pointer
local base_point_derived = v.Derived.NewDerived()
assert(base_point_derived:val1() == 11, "base_point_derived fail calling Derived::val1()")
assert(base_point_derived:val2() == 2, "base_point_derived fail calling Base::val2()")
-- Dynamic cast to original Derived class
local derived_dyn = v.dynDerivedCast(base_point_derived)
assert(derived_dyn ~= nil, "dynamic cast to derived_dyn fail")
assert(derived_dyn:val1() == 11, "derived_dyn fail calling Derived::val1()")
assert(derived_dyn:val2() == 12, "derived_dyn fail calling Derived::val2()")
-- Static cast work the same as dynamic cast, when used with the derived class!
local derived_static = v.staticDerivedCast(base_point_derived)
assert(derived_static ~= nil, "static cast to derived_static fail")
assert(derived_static:val1() == 11, "derived_static fail calling Derived::val1()")
assert(derived_static:val2() == 12, "derived_static fail calling Derived::val2()")

-- Get an Other object using a Base pointer
local base_point_other = v.Other.NewOther()
assert(base_point_other:val1() == 21, "base_point_other fail calling Other::val1()")
assert(base_point_other:val2() == 2, "base_point_other fail calling Base::val2()")
-- Dynamic cast to original Other class
local other_dyn = v.dynOtherCast(base_point_other)
assert(other_dyn ~= nil, "dynamic cast to other_dyn fail")
assert(other_dyn:val1() == 21, "other_dyn fail calling Other::val1()")
assert(other_dyn:val2() == 22, "other_dyn fail calling Other::val2()")
-- Static cast work the same as dynamic cast, when used with the other class!
local other_static = v.staticOtherCast(base_point_other)
assert(other_static ~= nil, "static cast to other_static fail")
assert(other_static:val1() == 21, "other_static fail calling Other::val1()")
assert(other_static:val2() == 22, "other_static fail calling Other::val2()")

-- Get a Base object
local base = v.Base()
assert(base:val1() == 1, "base fail calling Base::val1()")
assert(base:val2() == 2, "base fail calling Base::val2()")

-- Dynamic cast gives NULL as expected
assert(v.dynOtherCast(base_point_derived) == nil, "'Derived' object can not cast to 'Other'")
assert(v.dynDerivedCast(base_point_other) == nil, "'Other' object can not cast to 'Derived'")
assert(v.dynOtherCast(base) == nil, "'Base' object can not cast to 'Other'")
assert(v.dynDerivedCast(base) == nil, "'Base' object can not cast to 'Derived'")

-- Static cast gives a hybrid result
-- The virtual method point to original object class, as we expect!
-- While the non-virtual method uses the new pointed class method!
local non_cpp_other_derived = v.staticOtherCast(base_point_derived)
assert(non_cpp_other_derived ~= nil, "static cast to non_cpp_other_derived fail")
assert(non_cpp_other_derived:val1() == 11, "non_cpp_other_derived fail calling Derived::val1()")
assert(non_cpp_other_derived:val2() == 22, "non_cpp_other_derived fail calling Other::val2()")
local non_cpp_derived_other = v.staticDerivedCast(base_point_other)
assert(non_cpp_derived_other ~= nil, "static cast to non_cpp_derived_other fail")
assert(non_cpp_derived_other:val1() == 21, "non_cpp_derived_other fail calling Other::val1()")
assert(non_cpp_derived_other:val2() == 12, "non_cpp_derived_other fail calling Derived::val2()")
local non_cpp_base_derived = v.staticDerivedCast(base)
assert(non_cpp_base_derived ~= nil, "static cast to non_cpp_base_derived fail")
assert(non_cpp_base_derived:val1() == 1, "non_cpp_base_derived fail calling Base::val1()")
assert(non_cpp_base_derived:val2() == 12, "non_cpp_base_derived fail calling Derived::val2()")
local non_cpp_base_other = v.staticOtherCast(base)
assert(non_cpp_base_other ~= nil, "static cast to non_cpp_base_other fail")
assert(non_cpp_base_other:val1() == 1, "non_cpp_base_other fail calling Base::val1()")
assert(non_cpp_base_other:val2() == 22, "non_cpp_base_other fail calling Other::val2()")
