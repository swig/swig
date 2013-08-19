use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('virtual_derivation') }
require_ok('virtual_derivation');

#
# very innocent example
#
my $b = virtual_derivation::B->new(3);
is($b->get_a(), $b->get_b(), "something is really wrong");
