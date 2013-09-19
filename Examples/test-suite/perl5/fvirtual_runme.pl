use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('fvirtual') }
require_ok('fvirtual');

my $sw = fvirtual::NodeSwitch->new();
my $n = fvirtual::Node->new();
my $i = $sw->addChild($n);

is($i, 2, 'addChild');

