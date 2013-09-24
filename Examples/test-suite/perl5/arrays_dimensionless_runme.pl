use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('arrays_dimensionless') }
require_ok('arrays_dimensionless');

is(arrays_dimensionless::arr_int($arrays_dimensionless::globalints, 3), 600);
is(arrays_dimensionless::ptr_int($arrays_dimensionless::globalints, 3), 1200);

is(arrays_dimensionless::arr_int($arrays_dimensionless::Bar::ints, 3), 2400);
is(arrays_dimensionless::ptr_int($arrays_dimensionless::Bar::ints, 3), 4800);
