use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('smart_pointer_multi') }
require_ok('smart_pointer_multi');

my $f = smart_pointer_multi::Foo->new();
my $b = smart_pointer_multi::Bar->new($f);
my $s = smart_pointer_multi::Spam->new($b);
my $g = smart_pointer_multi::Grok->new($b);

$s->{x} = 3;
is($s->getx(), 3);
$g->{x} = 4;
is($g->getx(), 4);
