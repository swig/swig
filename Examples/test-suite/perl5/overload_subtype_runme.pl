use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('overload_subtype') }
require_ok('overload_subtype');

my $f = overload_subtype::Foo->new();
my $b = overload_subtype::Bar->new();

is(overload_subtype::spam($f), 1, 'foo');
is(overload_subtype::spam($b), 2, 'bar');
