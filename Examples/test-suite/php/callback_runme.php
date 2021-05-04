<?php

require "tests.php";

// In 2.0.6 and earlier, the constant was misnamed.
check::equal(gettype(callback::FOO_I_Cb_Ptr), 'object', "callback::FOO_I_Cb_Ptr not an object");

check::equal(get_class(callback::FOO_I_Cb_Ptr), 'SWIG\_p_f_int__int', "callback::FOO_I_Cb_Ptr not expected class");

check::done();
