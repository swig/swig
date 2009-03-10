use strict;
use warnings;
use Test::More 'no_plan';
BEGIN{ use_ok 'overload_copy' }
require_ok 'overload_copy';

my $f = overload_copy::Foo->new();
isa_ok($f, 'overload_copy::Foo');
my $g = overload_copy::Foo->new($f);
isa_ok($g, 'overload_copy::Foo');
