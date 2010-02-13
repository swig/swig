use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok 'smart_pointer_simple' }
require_ok 'smart_pointer_simple';

my $f = smart_pointer_simple::Foo->new();
isa_ok $f, 'smart_pointer_simple::Foo';
my $g = smart_pointer_simple::Bar->new($f);
isa_ok $g, 'smart_pointer_simple::Bar';

$g->{x} = 3;
is($g->getx(), 3);

my $fp = $$g;
is($fp, $f);
$fp->{x} = 4;
is($fp->getx, 4);

