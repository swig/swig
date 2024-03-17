use strict;
use warnings;
use Test::More tests => 17;
BEGIN { use_ok('cpp17_string_view') }
require_ok('cpp17_string_view');

use Devel::Peek;
# Checking expected use of %typemap(in) std::string_view {}
cpp17_string_view::test_value("Fee");

# Checking expected result of %typemap(out) std::string_view {}
is(cpp17_string_view::test_value("Fi"), "Fi", "Test 1");


# Verify type-checking for %typemap(in) std::string_view {}
eval { cpp17_string_view::test_value(undef) };
like($@, qr/\bTypeError\b/, "Test 2");

# Checking expected use of %typemap(in) const std::string_view & {}
cpp17_string_view::test_const_reference("Fo");

# Checking expected result of %typemap(out) const std::string_view& {}
is(cpp17_string_view::test_const_reference("Fum"), "Fum", "Test 3");

# Verify type-checking for %typemap(in) const std::string_view & {}
eval { cpp17_string_view::test_const_reference(undef) };
like($@, qr/\bValueError\b/, "Test 4");

#
# Input and output typemaps for pointers and non-const references to
# std::string_view are *not* supported; the following tests confirm
# that none of these cases are slipping through.
#

my $stringPtr = undef;

$stringPtr = cpp17_string_view::test_pointer_out();

cpp17_string_view::test_pointer($stringPtr);

$stringPtr = cpp17_string_view::test_const_pointer_out();

cpp17_string_view::test_const_pointer($stringPtr);

$stringPtr = cpp17_string_view::test_reference_out();

cpp17_string_view::test_reference($stringPtr);

# Check throw exception specification
eval { cpp17_string_view::test_throw() };
like($@, qr/^test_throw message/, "Test 5");
{ local $TODO = "why is the error not a Perl string?";
eval { cpp17_string_view::test_const_reference_throw() };
is($@, "<some kind of string>", "Test 6");
}

# Global variables
is($cpp17_string_view::ConstGlobalString, "const global string", "ConstGlobalString test");

# Member variables
my $myStructure = new cpp17_string_view::Structure();
is($myStructure->{ConstMemberString}, "const member string", "ConstMemberString test");

is($cpp17_string_view::Structure::ConstStaticMemberString, "const static member string", "ConstStaticMemberString test");


is(cpp17_string_view::stdstringview_empty(), "", "stdstringview_empty");

is(cpp17_string_view::c_empty(), "", "c_empty");


is(cpp17_string_view::c_null(), undef, "c_null");


is(cpp17_string_view::get_null(cpp17_string_view::c_null()), undef, "get_null c_null");

is(cpp17_string_view::get_null(cpp17_string_view::c_empty()), "non-null", "get_null c_empty");

is(cpp17_string_view::get_null(cpp17_string_view::stdstringview_empty()), "non-null", "get_null stdstringview_empty");
