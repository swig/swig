use strict;
use warnings;
use Test::More tests => 10;
BEGIN { use_ok('struct_initialization') }
require_ok('struct_initialization');

is($struct_initialization::instanceA1->{x}, 0);
is($struct_initialization::instanceB1->{x}, 0);
is($struct_initialization::instanceB2->{x}, 0);
is($struct_initialization::instanceB3->{x}, 0);
is($struct_initialization::instanceC1->{x}, 10);
is($struct_initialization::instanceD1->{x}, 10);
is($struct_initialization::instanceD2->{x}, 20);
is($struct_initialization::instanceD3->{x}, 30);
# these tests pass, but I'm not sure they should.
# they are arrays, but we seem to be surfacing only the first value
#is($struct_initialization::instanceE1->{x}, 1);
#is($struct_initialization::instanceF1->{x}, 1);
#is($struct_initialization::instanceF2->{x}, -1);
#is($struct_initialization::instanceF3->{x}, 11);
