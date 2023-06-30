<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('cpp11_auto_variable'));
check::globals(array('f', 't', 'la', 'da', 'fa', 'lc', 'dc', 'fc', 'pi_approx', 'Bar', 'Bar2', 'Foo', 'Foo2'));

check::equal(f_get(), false);
check::equal(t_get(), true);

t_set(false);
check::equal(t_get(), false);

check::equal(function_exists('f_set'), false, "f should be constant but f_set() exists");

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
