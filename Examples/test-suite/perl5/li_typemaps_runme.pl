#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 631;
BEGIN { use_ok('li_typemaps') }
require_ok('li_typemaps');

my @tests = qw(
  in inr
  out outr
  inout inoutr
);

sub should_pass { my($type, @values) = @_;
  # verify that each value passes cleanly
  for my $test (@tests) {
    my $name = "${test}_${type}";
    my $func = li_typemaps->can($name);
    for my $val (@values) {
      my $rv = eval { $func->($val) };
      is($rv, $val, "$name $val");
    }
  }
}

sub should_fail { my($type, @values) = @_;
  # verify that all values trigger runtime errors
  for my $test (@tests) {
    my $name = "${test}_${type}";
    my $func = li_typemaps->can($name);
    for my $val (@values) {
      my $rv = eval { $func->($val) };
      like($@, qr/\b(?:Overflow|Type)Error\b/, "overflow $name $val");
    }
  }
}

sub pad { my($t, $s, $f) = @_;
  my $nbytes = length pack $t, 0;
  return unpack $t, $s . ($f x ($nbytes - 1));
}

# some edge case values:
my $nan = unpack 'f>', "\x7f\xc0\x00\x00";
my $inf = unpack 'f>', "\x7f\x80\x00\x00";
my $char_min   = pad 'c', "\x80";
my $char_max   = pad 'c', "\x7f";
my $char_umax  = pad 'C', "\xff";
my $short_min  = pad 's!>', "\x80", "\x00";
my $short_max  = pad 's!>', "\x7f", "\xff";
my $short_umax = pad 'S!>', "\xff", "\xff";
my $int_min    = pad 'i!>', "\x80", "\x00";
my $int_max    = pad 'i!>', "\x7f", "\xff";
my $int_umax   = pad 'I!>', "\xff", "\xff";
my $long_min   = pad 'l!>', "\x80", "\x00";
my $long_max   = pad 'l!>', "\x7f", "\xff";
my $long_umax  = pad 'L!>', "\xff", "\xff";

should_pass('bool', '', 1);
should_pass('int', $int_min, -1, 0, 1, 12, $int_max);
should_fail('int', $int_min - 1000, $int_max + 1000, $inf, $nan);
should_pass('long', $long_min, -1, 0, 1, 12, $long_max);
should_fail('long', $long_min - 8000, $long_max + 8000, $inf, $nan);
should_pass('short', $short_min, -1, 0, 1, 12, $short_max);
should_fail('short', $short_min - 1, $short_max + 1, $inf, $nan);
should_pass('uint', 0, 1, 12, $int_umax);
should_fail('uint', -1, $int_umax + 1000, $inf, $nan);
should_pass('ushort', 0, 1, 12, $short_umax);
should_fail('ushort', -1, $short_umax + 1, $inf, $nan);
should_pass('ulong', 0, 1, 12, $long_umax);
should_fail('ulong', -1, $long_umax + 8000, $inf, $nan);
should_pass('uchar', 0, 1, 12, $char_umax);
should_fail('uchar', -1, $char_umax + 1, $inf, $nan);
should_pass('schar', $char_min, -1, 0, 1, 12, $char_max);
should_fail('schar', $char_min - 1, $char_max + 1, $inf, $nan);
should_pass('float', -1, 0, 1, $nan);
TODO: {
  local $TODO = "typemaps don't allow float infinity";
  should_pass('float', -$inf, $inf);
}
should_pass('double', -$inf, -1, 0, 1, $inf, $nan);
should_pass('longlong', -1, 0, 1, 12);
should_fail('longlong', $inf, $nan);
should_pass('ulonglong', 0, 1, 12);
should_fail('ulonglong', -1, $inf, $nan);
SKIP: {
  my $llong_min  = eval { pad 'q>', "\x80", "\x00" };
  my $llong_max  = eval { pad 'q>', "\x7f", "\xff" };
  my $llong_umax = eval { pad 'Q>', "\xff", "\xff" };

  skip 'not a 64 bit perl', 6 * 6 unless defined $llong_min;

  should_pass('longlong', $llong_min, $llong_max);
  should_fail('longlong', $llong_min - 8000, $llong_max + 8000);
  should_pass('ulonglong', $llong_umax);
  should_fail('ulonglong', $llong_umax + 8000);
}

my($foo, $int) = li_typemaps::out_foo(10);
isa_ok($foo, 'li_typemaps::Foo');
is($foo->{a}, 10);
is($int, 20);

my($a, $b) = li_typemaps::inoutr_int2(13, 31);
is($a, 13);
is($b, 31);
