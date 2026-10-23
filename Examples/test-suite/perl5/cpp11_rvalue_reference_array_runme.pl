use strict;
use warnings;
use Test::More tests => 18;
BEGIN { use_ok('cpp11_rvalue_reference_array') }
require_ok('cpp11_rvalue_reference_array');

# An rvalue reference to an array is passed as a reference to an array, which cannot be undef.
is(cpp11_rvalue_reference_array::sum_of(cpp11_rvalue_reference_array::others_address()), 100, "sum_of");
is(cpp11_rvalue_reference_array::first_of(cpp11_rvalue_reference_array::others_unsized_address()), 10, "first_of");
is(cpp11_rvalue_reference_array::items_sum(cpp11_rvalue_reference_array::items_address()), 3, "items_sum");
eval { cpp11_rvalue_reference_array::sum_of(undef) };
like($@, qr/invalid null reference/, "sum_of(undef)");
eval { cpp11_rvalue_reference_array::first_of(undef) };
like($@, qr/invalid null reference/, "first_of(undef)");

# An rvalue reference to an array of char is a string.
is(cpp11_rvalue_reference_array::length_of("abc"), 3, "length_of");
is(cpp11_rvalue_reference_array::length_of_writable("xy"), 2, "length_of_writable");
eval { cpp11_rvalue_reference_array::length_of(undef) };
like($@, qr/invalid null reference/, "length_of(undef)");

# Setting a variable that is an rvalue reference to an array copies into the array it refers to.
is(cpp11_rvalue_reference_array::numbers_sum(), 10, "numbers_sum");
$cpp11_rvalue_reference_array::numbers_rref = $cpp11_rvalue_reference_array::others;
is(cpp11_rvalue_reference_array::numbers_sum(), 100, "numbers_sum after set");
is($cpp11_rvalue_reference_array::letters_rref, "abc", "letters_rref");
$cpp11_rvalue_reference_array::letters_rref = "xy";
is(cpp11_rvalue_reference_array::letters_are(), "xy", "letters_are");

my $member = cpp11_rvalue_reference_array::RvalueRefArrayMember->new();
is($member->sum(), 10, "member sum");
$member->{member_rref} = cpp11_rvalue_reference_array::others_address();
is($member->sum(), 100, "member sum after set");
is($member->{text_rref}, "hi", "member text_rref");
$member->{text_rref} = "bye";
is($member->text_is(), "bye", "member text_is");
