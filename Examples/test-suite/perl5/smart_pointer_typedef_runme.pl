use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('smart_pointer_typedef') }
require_ok('smart_pointer_typedef');

my $f = smart_pointer_typedef::Foo->new();
my $b = smart_pointer_typedef::Bar->new($f);

$b->{x} = 3;
is($b->getx(), 3);

my $fp = $$b;
$fp->{x} = 4;
is($fp->getx(), 4);
