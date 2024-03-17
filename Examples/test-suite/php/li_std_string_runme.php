<?php

require "tests.php";

# Checking expected use of %typemap(in) std::string {}
li_std_string::test_value("Fee");

# Checking expected result of %typemap(out) std::string {}
check::equal(li_std_string::test_value("Fi"), "Fi", "Test 1");

# Checking expected use of %typemap(in) const std::string & {}
li_std_string::test_const_reference("Fo");

# Checking expected result of %typemap(out) const std::string& {}
check::equal(li_std_string::test_const_reference("Fum"), "Fum", "Test 3");

# Input and output typemaps for pointers and non-const references to
# std::string are *not* supported; the following tests confirm
# that none of these cases are slipping through.

$stringPtr = li_std_string::test_pointer_out();

li_std_string::test_pointer($stringPtr);

$stringPtr = li_std_string::test_const_pointer_out();

li_std_string::test_const_pointer($stringPtr);

$stringPtr = li_std_string::test_reference_out();

li_std_string::test_reference($stringPtr);

// Global variables
$s = "initial string";
check::equal(GlobalString2_get(), "global string 2", "GlobalString2 test 1");
GlobalString2_set($s);
check::equal(GlobalString2_get(), $s, "GlobalString2 test 2");
check::equal(ConstGlobalString_get(), "const global string", "ConstGlobalString test");

// Member variables
$myStructure = new Structure();
check::equal($myStructure->MemberString2, "member string 2", "MemberString2 test 1");
$myStructure->MemberString2 = $s;
check::equal($myStructure->MemberString2, $s, "MemberString2 test 2");
check::equal($myStructure->ConstMemberString, "const member string", "ConstMemberString test");

check::equal(Structure::StaticMemberString2(), "static member string 2", "StaticMemberString2 test 1");
Structure::StaticMemberString2($s);
check::equal(Structure::StaticMemberString2(), $s, "StaticMemberString2 test 2");
check::equal(Structure::ConstStaticMemberString(), "const static member string", "ConstStaticMemberString test");

// Test INPUT, INOUT and OUTPUT string& typemaps:
$input = "hello";
check::equal(li_std_string::test_reference_input($input), "hello");
// $input should be unchanged - this check is to catch if we incorrectly used
// the default string& typemap:
check::equal($input, "hello");
$s = li_std_string::test_reference_inout($input);
check::equal($s, "hellohello");
// $input should be unchanged - this check is to catch if we incorrectly used
// the default string& typemap:
check::equal($input, "hello");
check::equal(li_std_string::test_reference_output(), "output");

// Test default PHP wrapping of std::string& as a by-ref PHP string parameter:
$s = "byref";
check::equal(li_std_string::test_reference_php($s), null);
check::equal($s, "byref.php");

// Test throwing strings:
try {
    test_throw();
    check::fail("test_throw() didn't throw");
} catch (Exception $s) {
    check::equal($s->getMessage(), "test_throw message");
}
try {
    test_const_reference_throw();
    check::fail("test_const_reference_throw() didn't throw");
} catch (Exception $s) {
    check::equal($s->getMessage(), "test_const_reference_throw message");
}
try {
    test_pointer_throw();
    check::fail("test_pointer_throw() didn't throw");
} catch (Exception $s) {
    check::equal($s->getMessage(), "foo");
}
try {
    test_const_pointer_throw();
    check::fail("test_const_pointer_throw() didn't throw");
} catch (Exception $s) {
    check::equal($s->getMessage(), "foo");
}

check::equal(li_std_string::stdstring_empty(), "", "stdstring_empty test");
check::equal(li_std_string::c_empty(), "", "c_empty test");
check::isnull(li_std_string::c_null(), "c_null test");
check::isnull(li_std_string::get_null(li_std_string::c_null()), "get_null c_null test");
check::equal(li_std_string::get_null(li_std_string::c_empty()), "non-null", "get_null c_empty test");
check::equal(li_std_string::get_null(li_std_string::stdstring_empty()), "non-null", "get_null stdstring_empty test");

// This used to give "Undefined variable: r"
li_std_string::test_const_reference_returning_void("foo");

check::done();
