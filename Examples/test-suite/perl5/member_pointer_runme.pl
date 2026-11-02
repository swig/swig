use strict;
use warnings;
use Test::More tests => 21;
# member_pointer using pointers to member functions

BEGIN { use_ok('member_pointer') }
require_ok('member_pointer');

sub check($;$;$) {
  my($what, $expected, $actual) = @_;
  if ($expected != $actual) {
    die ("Failed: $what Expected: $expected Actual: $actual");
  }
}

# Get the pointers

my $area_pt = member_pointer::areapt();
my $perim_pt = member_pointer::perimeterpt();

# Create some objects

my $s = new member_pointer::Square(10);

# Do some calculations

is(100.0, member_pointer::do_op($s,$area_pt), "Square area");
is(40.0, member_pointer::do_op($s,$perim_pt), "Square perim");
no strict;

my $memberPtr = $member_pointer::areavar;
$memberPtr = $member_pointer::perimetervar;

# Try the variables
is(100.0, member_pointer::do_op($s,$member_pointer::areavar), "Square area");
is(40.0, member_pointer::do_op($s,$member_pointer::perimetervar), "Square perim");

# Modify one of the variables
$member_pointer::areavar = $perim_pt;

is(40.0, member_pointer::do_op($s,$member_pointer::areavar), "Square perimeter");

# Try the constants

$memberPtr = $member_pointer::AREAPT;
$memberPtr = $member_pointer::PERIMPT;
$memberPtr = $member_pointer::NULLPT;

is(100.0, member_pointer::do_op($s,$member_pointer::AREAPT), "Square area");
is(40.0, member_pointer::do_op($s,$member_pointer::PERIMPT), "Square perim");

# Const references to member pointers

is(100.0, member_pointer::do_op_cref($s,$area_pt), "Square area");
is(40.0, member_pointer::do_op_cref($s,member_pointer::perimetervar_td_cref()), "Square perim");
is(40.0, member_pointer::do_op($s,member_pointer::perimetervar_td_cref()), "Square perim");
eval { member_pointer::do_op_cref($s,$member_pointer::ADD_BY_VALUE) };
like($@, qr/\bTypeError\b/, "do_op_cref with ADD_BY_VALUE");

# Overloaded on the member pointer type

is(3, member_pointer::call_overloaded($member_pointer::ADD_BY_VALUE, 1, 2), "Overload by value");
is(-7, member_pointer::call_overloaded($member_pointer::ADD_BY_POINTER, 3, 4), "Overload by pointer");
is(110, member_pointer::call_overloaded(10, 5, 6), "Overload by int");

# Overloaded on a member pointer and a pointer, only the pointer taking undef

my $f = new member_pointer::Funktions();
is(3, member_pointer::memberpt_or_pointer($member_pointer::ADD_BY_VALUE), "Overload by member pointer");
is(10, member_pointer::memberpt_or_pointer($f), "Overload by pointer");
is(20, member_pointer::memberpt_or_pointer(undef), "Overload by undef");

# A pointer is not a member pointer

my $int_ptr = $f->addByPointer(1, 2);
eval { member_pointer::do_op($s, $int_ptr) };
like($@, qr/\bTypeError\b/, "do_op with an int pointer");
eval { member_pointer::memberpt_or_pointer($int_ptr) };
like($@, qr/\bNo matching function\b/, "memberpt_or_pointer with an int pointer");
