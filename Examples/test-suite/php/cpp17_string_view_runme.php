<?php

require "tests.php";

# Checking expected use of %typemap(in) std::string_view {}
cpp17_string_view::test_value("Fee");

# Checking expected result of %typemap(out) std::string_view {}
check::equal(cpp17_string_view::test_value("Fi"), "Fi", "Test 1");

# Checking expected use of %typemap(in) const std::string_view & {}
cpp17_string_view::test_const_reference("Fo");

# Checking expected result of %typemap(out) const std::string_view& {}
check::equal(cpp17_string_view::test_const_reference("Fum"), "Fum", "Test 3");

# Input and output typemaps for pointers and non-const references to
# std::string_view are *not* supported; the following tests confirm
# that none of these cases are slipping through.

$stringPtr = cpp17_string_view::test_pointer_out();

cpp17_string_view::test_pointer($stringPtr);

$stringPtr = cpp17_string_view::test_const_pointer_out();

cpp17_string_view::test_const_pointer($stringPtr);

$stringPtr = cpp17_string_view::test_reference_out();

cpp17_string_view::test_reference($stringPtr);

// Global variables
check::equal(ConstGlobalString_get(), "const global string", "ConstGlobalString test");

// Member variables
$myStructure = new Structure();
check::equal($myStructure->ConstMemberString, "const member string", "ConstMemberString test");

check::equal(Structure::ConstStaticMemberString(), "const static member string", "ConstStaticMemberString test");

cpp17_string_view::test_const_reference_returning_void("foo");

check::equal(cpp17_string_view::stdstringview_empty(), "", "stdstringview_empty test");
check::equal(cpp17_string_view::c_empty(), "", "c_empty test");
check::isnull(cpp17_string_view::c_null(), "c_null test");
check::isnull(cpp17_string_view::get_null(cpp17_string_view::c_null()), "get_null c_null test");
check::equal(cpp17_string_view::get_null(cpp17_string_view::c_empty()), "non-null", "get_null c_empty test");
check::equal(cpp17_string_view::get_null(cpp17_string_view::stdstringview_empty()), "non-null", "get_null stdstringview_empty test");

check::done();
