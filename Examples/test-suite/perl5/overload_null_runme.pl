use strict;
use warnings;
use Test::More tests => 24;
BEGIN { use_ok('overload_null') }
require_ok('overload_null');

my $o = new overload_null::Overload();
my $x = new overload_null::X();

is(1, $o->byval1($x));
is(2, $o->byval1(undef));

is(3, $o->byval2(undef));
is(4, $o->byval2($x));

is(5, $o->byref1($x));
is(6, $o->byref1(undef));

is(7, $o->byref2(undef));
is(8, $o->byref2($x));

is(9, $o->byconstref1($x));
is(10, $o->byconstref1(undef));

is(11, $o->byconstref2(undef));
is(12, $o->byconstref2($x));

# const pointer references
is(13, $o->byval1cpr($x));
is(14, $o->byval1cpr(undef));

is(15, $o->byval2cpr(undef));
is(16, $o->byval2cpr($x));

# forward class declaration
is(17, $o->byval1forwardptr($x));
is(18, $o->byval1forwardptr(undef));

is(19, $o->byval2forwardptr(undef));
is(20, $o->byval2forwardptr($x));

is(21, $o->byval1forwardref($x));

is(22, $o->byval2forwardref($x));
