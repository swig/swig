if [ catch { load ./li_cpointer_dynamic_cast[info sharedlibextension] Li_cpointer_dynamic_cast} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

proc swig_assert_equal { a b msg } {
	if { $a != $b } {
		puts stderr $msg
		exit 1
	}
}
proc swig_assert_not_null {o msg} {
	if { $o == "NULL" } {
		puts stderr $msg
		exit 1
	}
}
proc swig_assert_is_null {o msg} { swig_assert_equal $o "NULL" $msg }

# Get a Derived object using a Base pointer
set base_point_derived [ Derived_NewDerived ]
swig_assert_equal [ $base_point_derived val1 ] 11 "base_point_derived fail calling Derived::val1()"
swig_assert_equal [ $base_point_derived val2 ] 2 "base_point_derived fail calling Base::val2()"
# Dynamic cast to original Derived class
set derived_dyn [ dynDerivedCast $base_point_derived ]
swig_assert_not_null $derived_dyn "dynamic cast to derived_dyn fail"
swig_assert_equal [ $derived_dyn val1 ] 11 "derived_dyn fail calling Derived::val1()"
swig_assert_equal [ $derived_dyn val2 ] 12 "derived_dyn fail calling Derived::val2()"
# Static cast work the same as dynamic cast, when used with the derived class!
set derived_static [ staticDerivedCast $base_point_derived ]
swig_assert_not_null $derived_static "static cast to derived_static fail"
swig_assert_equal [ $derived_static val1 ] 11 "derived_static fail calling Derived::val1()"
swig_assert_equal [ $derived_static val2 ] 12 "derived_static fail calling Derived::val2()"

# Get an Other object using a Base pointer
set base_point_other [ Other_NewOther ]
swig_assert_equal [ $base_point_other val1 ] 21 "base_point_other fail calling Other::val1()"
swig_assert_equal [ $base_point_other val2 ] 2 "base_point_other fail calling Base::val2()"
# Dynamic cast to original Other class
set other_dyn [ dynOtherCast $base_point_other ]
swig_assert_not_null $other_dyn "dynamic cast to other_dyn fail"
swig_assert_equal [ $other_dyn val1 ] 21 "other_dyn fail calling Other::val1()"
swig_assert_equal [ $other_dyn val2 ] 22 "other_dyn fail calling Other::val2()"
# Static cast work the same as dynamic cast, when used with the other class!
set other_static [ staticOtherCast $base_point_other ]
swig_assert_not_null $other_static "static cast to other_static fail"
swig_assert_equal [ $other_static val1 ] 21 "other_static fail calling Other::val1()"
swig_assert_equal [ $other_static val2 ] 22 "other_static fail calling Other::val2()"

# Get a Base object
set base [ Base ]
swig_assert_equal [ $base val1 ] 1 "base fail calling Base::val1()"
swig_assert_equal [ $base val2 ] 2 "base fail calling Base::val2()"

# Dynamic cast gives NULL as expected
swig_assert_is_null [ dynOtherCast $base_point_derived ] "'Derived' object can not cast to 'Other'"
swig_assert_is_null [ dynDerivedCast $base_point_other ] "'Other' object can not cast to 'Derived'"
swig_assert_is_null [ dynOtherCast $base ] "'Base' object can not cast to 'Other'"
swig_assert_is_null [ dynDerivedCast $base ] "'Base' object can not cast to 'Derived'"

# Static cast gives a hybrid result
# The virtual method point to original object class, as we expect!
# While the non-virtual method uses the new pointed class method!
set non_cpp_other_derived [ staticOtherCast $base_point_derived ]
swig_assert_not_null $non_cpp_other_derived "static cast to non_cpp_other_derived fail"
swig_assert_equal [ $non_cpp_other_derived val1 ] 11 "non_cpp_other_derived fail calling Derived::val1()"
swig_assert_equal [ $non_cpp_other_derived val2 ] 22 "non_cpp_other_derived fail calling Other::val2()"
set non_cpp_derived_other [ staticDerivedCast $base_point_other ]
swig_assert_not_null $non_cpp_derived_other "static cast to non_cpp_derived_other fail"
swig_assert_equal [ $non_cpp_derived_other val1 ] 21 "non_cpp_derived_other fail calling Other::val1()"
swig_assert_equal [ $non_cpp_derived_other val2 ] 12 "non_cpp_derived_other fail calling Derived::val2()"
set non_cpp_base_derived [ staticDerivedCast $base ]
swig_assert_not_null $non_cpp_base_derived "static cast to non_cpp_base_derived fail"
swig_assert_equal [ $non_cpp_base_derived val1 ] 1 "non_cpp_base_derived fail calling Base::val1()"
swig_assert_equal [ $non_cpp_base_derived val2 ] 12 "non_cpp_base_derived fail calling Derived::val2()"
set non_cpp_base_other [ staticOtherCast $base ]
swig_assert_not_null $non_cpp_base_other "static cast to non_cpp_base_other fail"
swig_assert_equal [ $non_cpp_base_other val1 ] 1 "non_cpp_base_other fail calling Base::val1()"
swig_assert_equal [ $non_cpp_base_other val2 ] 22 "non_cpp_base_other fail calling Other::val2()"
