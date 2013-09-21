use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('template_extend1') }
require_ok('template_extend1');

my $a = template_extend1::lBaz->new();
my $b = template_extend1::dBaz->new();

is($a->foo(), 'lBaz::foo');
is($b->foo(), 'dBaz::foo');
