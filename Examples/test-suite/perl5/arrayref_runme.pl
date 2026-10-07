use strict;
use warnings;
use Test::More tests => 13;
BEGIN { use_ok('arrayref') }
require_ok('arrayref');

# Setting a variable that is a reference to an array copies into the array it refers to.
is(arrayref::numbers_sum(), 10, "numbers_sum");
$arrayref::numbers_ref = $arrayref::others;
is(arrayref::numbers_sum(), 100, "numbers_sum after set");

# An array of char is a string here, and so is a reference to one.
is($arrayref::letters, "abc", "letters");
is($arrayref::letters_ref, "abc", "letters_ref");
$arrayref::letters_ref = "xy";
is(arrayref::letters_are(), "xy", "letters_are");
is($arrayref::frozen_ref, "xyz", "frozen_ref");

my $member = arrayref::ArrayRefMember->new();
is($member->sum(), 10, "member sum");

# Setting a reference to an array of arrays copies every element.
$arrayref::grid_ref = $arrayref::other_grid;
is(arrayref::grid_element(0, 1), 20, "grid_element(0, 1)");
is(arrayref::grid_element(1, 2), 60, "grid_element(1, 2)");

my $grid_member = arrayref::GridRefMember->new();
$grid_member->{rows_ref} = arrayref::other_grid_address();
is($grid_member->element(0, 1), 20, "grid member element(0, 1)");
is($grid_member->element(1, 2), 60, "grid member element(1, 2)");
