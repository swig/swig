use li_std_string;


# Checking expected use of %typemap(in) std::string {}
li_std_string::test_value("Fee");

# Checking expected result of %typemap(out) std::string {}
if (li_std_string::test_value("Fi") != "Fi") {
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
if (li_std_string::test_const_reference("Fum") != "Fum") {
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

