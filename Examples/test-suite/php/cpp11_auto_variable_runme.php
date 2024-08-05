<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('cpp11_auto_variable'));
check::globals(array('f', 't', 'zero', 'one', 'la', 'da', 'fa', 'lc', 'dc', 'fc', 'pi_approx', 'wstring_lit_len1', 'wstring_lit_len2', 'Bar', 'Bar2', 'Bar3', 'Foo', 'Foo2', 'Foo3', 'NOEXCEPT_FUNC'));

check::equal(f_get(), false);
check::equal(gettype(f_get()), "boolean");
check::equal(t_get(), true);
check::equal(gettype(t_get()), "boolean");

t_set(false);
check::equal(t_get(), false);

check::equal(function_exists('f_set'), false, "f should be constant but f_set() exists");

check::equal(zero_get(), 0);
check::equal(gettype(zero_get()), "integer");
check::equal(one_get(), 1);
check::equal(gettype(one_get()), "integer");

zero_set(42);
check::equal(zero_get(), 42);

check::equal(function_exists('one_set'), false, "one should be constant but one_set() exists");

check::equal(fa_get(), 1.0);
check::equal(da_get(), 1.0);
// PHP doesn't have a native "long double" type, so SWIG/PHP doesn't have
// typemaps for it and so it should get wrapped as an opaque type.
check::str_contains(la_get(), "SWIGPointer(");

check::equal(fc_get(), 1.0);
check::equal(dc_get(), 1.0);
// PHP doesn't have a native "long double" type, so SWIG/PHP doesn't have
// typemaps for it and so it should get wrapped as an opaque type.
check::str_contains(lc_get(), "SWIGPointer(");

check::equal(wstring_lit_len1_get(), 6);
check::equal(wstring_lit_len2_get(), 6);
