<?php

require "tests.php";

check::functions(array("staticDerivedCast", "dynDerivedCast", "staticOtherCast", "dynOtherCast"));
check::classes(array("Base", "Derived", "Other", "li_cpointer_dynamic_cast"));
check::globals(array());


# Get a Derived object using a Base pointer
$base_point_derived = Derived::NewDerived();
check::equal($base_point_derived->val1(), 11, "base_point_derived fail calling Derived::val1()");
check::equal($base_point_derived->val2(), 2, "base_point_derived fail calling Base::val2()");
# Dynamic cast to original Derived class
$derived_dyn = dynDerivedCast($base_point_derived);
check::equal($derived_dyn !== NULL, true, "dynamic cast to derived_dyn fail");
check::equal($derived_dyn->val1(), 11, "derived_dyn fail calling Derived::val1()");
check::equal($derived_dyn->val2(), 12, "derived_dyn fail calling Derived::val2()");
# Static cast work the same as dynamic cast, when used with the derived class!
$derived_static = staticDerivedCast($base_point_derived);
check::equal($derived_static !== NULL, true, "static cast to derived_static fail");
check::equal($derived_static->val1(), 11, "derived_static fail calling Derived::val1()");
check::equal($derived_static->val2(), 12, "derived_static fail calling Derived::val2()");

# Get an Other object using a Base pointer
$base_point_other = Other::NewOther();
check::equal($base_point_other->val1(), 21, "base_point_other fail calling Other::val1()");
check::equal($base_point_other->val2(), 2, "base_point_other fail calling Base::val2()");
# Dynamic cast to original Other class
$other_dyn = dynOtherCast($base_point_other);
check::equal($other_dyn !== NULL, true, "dynamic cast to other_dyn fail");
check::equal($other_dyn->val1(), 21, "other_dyn fail calling Other::val1()");
check::equal($other_dyn->val2(), 22, "other_dyn fail calling Other::val2()");
# Static cast work the same as dynamic cast, when used with the other class!
$other_static = staticOtherCast($base_point_other);
check::equal($other_static !== NULL, true, "static cast to other_static fail");
check::equal($other_static->val1(), 21, "other_static fail calling Other::val1()");
check::equal($other_static->val2(), 22, "other_static fail calling Other::val2()");

# Get a Base object
$baseObj = new Base;
check::equal($baseObj->val1(), 1, "base fail calling Base::val1()");
check::equal($baseObj->val2(), 2, "base fail calling Base::val2()");

# Dynamic cast gives NULL as expected
check::isnull(dynOtherCast($base_point_derived), "'Derived' object can not cast to 'Other'");
check::isnull(dynDerivedCast($base_point_other), "'Other' object can not cast to 'Derived'");
check::isnull(dynOtherCast($baseObj), "'Base' object can not cast to 'Other'");
check::isnull(dynDerivedCast($baseObj), "'Base' object can not cast to 'Derived'");

# Static cast gives a hybrid result
# The virtual method point to original object class, as we expect!
# While the non-virtual method uses the new pointed class method!
$non_cpp_other_derived = staticOtherCast($base_point_derived);
check::equal($non_cpp_other_derived !== NULL, true, "static cast to non_cpp_other_derived fail");
check::equal($non_cpp_other_derived->val1(), 11, "non_cpp_other_derived fail calling Derived::val1()");
check::equal($non_cpp_other_derived->val2(), 22, "non_cpp_other_derived fail calling Other::val2()");
$non_cpp_derived_other = staticDerivedCast($base_point_other);
check::equal($non_cpp_derived_other !== NULL, true, "static cast to non_cpp_derived_other fail");
check::equal($non_cpp_derived_other->val1(), 21, "non_cpp_derived_other fail calling Other::val1()");
check::equal($non_cpp_derived_other->val2(), 12, "non_cpp_derived_other fail calling Derived::val2()");
$non_cpp_base_derived = staticDerivedCast($baseObj);
check::equal($non_cpp_base_derived !== NULL, true, "static cast to non_cpp_base_derived fail");
check::equal($non_cpp_base_derived->val1(), 1, "non_cpp_base_derived fail calling Base::val1()");
check::equal($non_cpp_base_derived->val2(), 12, "non_cpp_base_derived fail calling Derived::val2()");
$non_cpp_base_other = staticOtherCast($baseObj);
check::equal($non_cpp_base_other !== NULL, true, "static cast to non_cpp_base_other fail");
check::equal($non_cpp_base_other->val1(), 1, "non_cpp_base_other fail calling Base::val1()");
check::equal($non_cpp_base_other->val2(), 22, "non_cpp_base_other fail calling Other::val2()");
