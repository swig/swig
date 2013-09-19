use strict;
use warnings;
use Test::More tests => 11;
BEGIN { use_ok('friends') }
require_ok('friends');

my $a = friends::A->new(2);
is(friends::get_val1($a), 2);
is(friends::get_val2($a), 4);
is(friends::get_val3($a), 6);

# nice overload working fine
is(friends::get_val1(1, 2, 3), 1);

my $b = friends::B->new(3);

# David's case
is(friends::mix($a,$b), 5);

my $di = friends::D_d->new(2);
my $dd = friends::D_d->new(3.3);

# incredible template overloading working just fine
is(friends::get_val1($di), 2);
is(friends::get_val1($dd), 3.3);

friends::set($di, 4);
friends::set($dd, 1.3);

is(friends::get_val1($di), 4);
is(friends::get_val1($dd), 1.3);
