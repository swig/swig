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

// This used to give "Undefined variable: r"
li_std_string::test_const_reference_returning_void("foo");

check::done();
