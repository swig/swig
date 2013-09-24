use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('smart_pointer_multi_typedef') }
require_ok('smart_pointer_multi_typedef');

my $f = smart_pointer_multi_typedef::Foo->new();
my $b = smart_pointer_multi_typedef::Bar->new($f);
my $s = smart_pointer_multi_typedef::Spam->new($b);
my $g = smart_pointer_multi_typedef::Grok->new($b);

$s->{x} = 3;
is($s->getx(), 3);
$g->{x} = 4;
is($g->getx(), 4);
