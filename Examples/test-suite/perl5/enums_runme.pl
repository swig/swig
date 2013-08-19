use strict;
use warnings;
use Test::More tests => 9;
BEGIN { use_ok('enums') }
require_ok('enums');

can_ok('enums', 'bar2');
enums::bar2(1);
can_ok('enums', 'bar3');
enums::bar3(1);
can_ok('enums', 'bar1');
enums::bar1(1);

is($enums::enumInstance, 2);
is($enums::Slap, 10);
is($enums::Mine, 11);
is($enums::Thigh, 12);

