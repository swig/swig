use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok('multivalue') }
require_ok('multivalue');

my ($q, $r);

($q, $r) = multivalue::divide_l(37, 5);
is($q, 7, "Test divide_l quotient");
is($r, 2, "Test divide_l remainder");

($q, $r) = multivalue::divide_v(41, 7);
is($q, 5, "Test divide_v quotient");
is($r, 6, "Test divide_v remainder");

($q, $r) = multivalue::divide_mv(91, 13);
is($q, 7, "Test divide_mv quotient");
is($r, 0, "Test divide_mv remainder");
