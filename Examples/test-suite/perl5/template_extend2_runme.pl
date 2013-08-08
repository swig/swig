use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('template_extend2') }
require_ok('template_extend2');

my $a = template_extend2::lBaz->new();
my $b = template_extend2::dBaz->new();

is($a->foo(), "lBaz::foo");
is($b->foo(), "dBaz::foo");
