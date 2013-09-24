use strict;
use warnings;
use Test::More tests => 7;
BEGIN { use_ok('anonymous_bitfield') }
require_ok('anonymous_bitfield');

my $obj = anonymous_bitfield::Foo->new();
$obj->{x} = 2;
$obj->{y} = 3;
$obj->{f} = 1;
$obj->{z} = 14000;
$obj->{seq} = 66;
is($obj->{x}, 2);
is($obj->{y}, 3);
is($obj->{f}, 1);
is($obj->{z}, 14000);
is($obj->{seq}, 66);
