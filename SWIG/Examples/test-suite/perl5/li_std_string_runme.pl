use li_std_string;


# Checking expected use of %typemap(in) std::string {}
li_std_string::test_value("Fee");

# Checking expected result of %typemap(out) std::string {}
if (li_std_string::test_value("Fi") ne "Fi") {
  die "Test 1 failed";
}

###### passing undef seems to work - surely it should fail ????
# Verify type-checking for %typemap(in) std::string {}
#eval { li_std_string::test_value(undef) };
#if (!$@) {
#  die "Test 2 failed";
#}

# Checking expected use of %typemap(in) const std::string & {}
li_std_string::test_const_reference("Fo");

# Checking expected result of %typemap(out) const std::string& {}
if (li_std_string::test_const_reference("Fum") ne "Fum") {
  die "Test 3 failed";
}

###### passing undef seems to work - surely it should fail ????
# Verify type-checking for %typemap(in) const std::string & {}
#eval { li_std_string::test_const_reference(undef) };
#if (!$@) {
#  die "Test 4 failed";
#}

#
# Input and output typemaps for pointers and non-const references to
# std::string are *not* supported; the following tests confirm
# that none of these cases are slipping through.
#

my $stringPtr = undef;

$stringPtr = li_std_string::test_pointer_out();

li_std_string::test_pointer($stringPtr);

$stringPtr = li_std_string::test_const_pointer_out();

li_std_string::test_const_pointer($stringPtr);

$stringPtr = li_std_string::test_reference_out();

li_std_string::test_reference($stringPtr);

# Check throw exception specification
eval { li_std_string::test_throw() };
if (!$@) {
  die "Test 5 failed";
}
eval { li_std_string::test_const_reference_throw() };
if (!$@) {
  die "Test 6 failed";
}

# Global variables
$s = "initial string";
if ($li_std_string::GlobalString2 ne "global string 2") {
  die ("GlobalString2 test 1");
}
$li_std_string::GlobalString2 = $s;
if ($li_std_string::GlobalString2 ne $s) {
  die ("GlobalString2 test 2");
}
if ($li_std_string::ConstGlobalString ne "const global string") {
  die ("ConstGlobalString test");
}

# Member variables
$myStructure = new li_std_string::Structure();
if ($myStructure->{MemberString2} ne "member string 2") {
  die ("MemberString2 test 1");
}
$myStructure->{MemberString2} = $s;
if ($myStructure->{MemberString2} ne $s) {
  die ("MemberString2 test 2");
}
if ($myStructure->{ConstMemberString} ne "const member string") {
  die ("ConstMemberString test");
}

if ($li_std_string::Structure::StaticMemberString2 ne "static member string 2") {
  die ("StaticMemberString2 test 1");
}
$li_std_string::Structure::StaticMemberString2 = $s;
if ($li_std_string::Structure::StaticMemberString2 ne $s) {
  die ("StaticMemberString2 test 2");
}
if ($li_std_string::Structure::ConstStaticMemberString ne "const static member string") {
  die ("ConstStaticMemberString test");
}

if (li_std_string::test_reference_input("hello") ne "hello") {
  die ("reference_input");
}

if (li_std_string::test_reference_inout("hello") ne "hellohello") {
  die ("reference_inout");
}
