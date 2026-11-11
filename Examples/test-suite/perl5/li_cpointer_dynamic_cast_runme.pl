use strict;
use warnings;
use Test::More tests => 36;
BEGIN { use_ok('li_cpointer_dynamic_cast') }
require_ok('li_cpointer_dynamic_cast');

# Get a Derived object using a Base pointer
my $base_point_derived = li_cpointer_dynamic_cast::Derived::NewDerived;
ok($base_point_derived->val1() == 11, "base_point_derived fail calling Derived::val1()");
ok($base_point_derived->val2() == 2, "base_point_derived fail calling Base::val2()");
# Dynamic cast to original Derived class
my $derived_dyn = li_cpointer_dynamic_cast::dynDerivedCast($base_point_derived);
ok($derived_dyn != undef, "dynamic cast to derived_dyn fail");
ok($derived_dyn->val1() == 11, "derived_dyn fail calling Derived::val1()");
ok($derived_dyn->val2() == 12, "derived_dyn fail calling Derived::val2()");
# Static cast work the same as dynamic cast, when used with the derived class!
my $derived_static = li_cpointer_dynamic_cast::staticDerivedCast($base_point_derived);
ok($derived_static != undef, "static cast to derived_static fail");
ok($derived_static->val1() == 11, "derived_static fail calling Derived::val1()");
ok($derived_static->val2() == 12, "derived_static fail calling Derived::val2()");

# Get an Other object using a Base pointer
my $base_point_other = li_cpointer_dynamic_cast::Other::NewOther;
ok($base_point_other->val1() == 21, "base_point_other fail calling Other::val1()");
ok($base_point_other->val2() == 2, "base_point_other fail calling Base::val2()");
# Dynamic cast to original Other class
my $other_dyn = li_cpointer_dynamic_cast::dynOtherCast($base_point_other);
ok($other_dyn != undef, "dynamic cast to other_dyn fail");
ok($other_dyn->val1() == 21, "other_dyn fail calling Other::val1()");
ok($other_dyn->val2() == 22, "other_dyn fail calling Other::val2()");
# Static cast work the same as dynamic cast, when used with the other class!
my $other_static = li_cpointer_dynamic_cast::staticOtherCast($base_point_other);
ok($other_static != undef, "static cast to other_static fail");
ok($other_static->val1() == 21, "other_static fail calling Other::val1()");
ok($other_static->val2() == 22, "other_static fail calling Other::val2()");

# Get a Base object
my $baseObj = li_cpointer_dynamic_cast::Base->new;
ok($baseObj->val1() == 1, "base fail calling Base::val1()");
ok($baseObj->val2() == 2, "base fail calling Base::val2()");

# Dynamic cast gives NULL as expected
ok(li_cpointer_dynamic_cast::dynOtherCast($base_point_derived) == undef, "'Derived' object can not cast to 'Other'");
ok(li_cpointer_dynamic_cast::dynDerivedCast($base_point_other) == undef, "'Other' object can not cast to 'Derived'");
ok(li_cpointer_dynamic_cast::dynOtherCast($baseObj) == undef, "'Base' object can not cast to 'Other'");
ok(li_cpointer_dynamic_cast::dynDerivedCast($baseObj) == undef, "'Base' object can not cast to 'Derived'");

# Static cast gives a hybrid result
# The virtual method point to original object class, as we expect!
# While the non-virtual method uses the new pointed class method!
my $non_cpp_other_derived = li_cpointer_dynamic_cast::staticOtherCast($base_point_derived);
ok($non_cpp_other_derived != undef, "static cast to non_cpp_other_derived fail");
ok($non_cpp_other_derived->val1() == 11, "non_cpp_other_derived fail calling Derived::val1()");
ok($non_cpp_other_derived->val2() == 22, "non_cpp_other_derived fail calling Other::val2()");
my $non_cpp_derived_other = li_cpointer_dynamic_cast::staticDerivedCast($base_point_other);
ok($non_cpp_derived_other != undef, "static cast to non_cpp_derived_other fail");
ok($non_cpp_derived_other->val1() == 21, "non_cpp_derived_other fail calling Other::val1()");
ok($non_cpp_derived_other->val2() == 12, "non_cpp_derived_other fail calling Derived::val2()");
my $non_cpp_base_derived = li_cpointer_dynamic_cast::staticDerivedCast($baseObj);
ok($non_cpp_base_derived != undef, "static cast to non_cpp_base_derived fail");
ok($non_cpp_base_derived->val1() == 1, "non_cpp_base_derived fail calling Base::val1()");
ok($non_cpp_base_derived->val2() == 12, "non_cpp_base_derived fail calling Derived::val2()");
my $non_cpp_base_other = li_cpointer_dynamic_cast::staticOtherCast($baseObj);
ok($non_cpp_base_other != undef, "static cast to non_cpp_base_other fail");
ok($non_cpp_base_other->val1() == 1, "non_cpp_base_other fail calling Base::val1()");
ok($non_cpp_base_other->val2() == 22, "non_cpp_base_other fail calling Other::val2()");
