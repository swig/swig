use strict;
use warnings;
use Test::More tests => 10;
BEGIN { use_ok('template_rename') }
require_ok('template_rename');

my $i = template_rename::iFoo->new();
isa_ok($i, 'template_rename::iFoo');
my $d = template_rename::dFoo->new();
isa_ok($d, 'template_rename::dFoo');

is($i->blah_test(4), 4);
is($i->spam_test(5), 5);
is($i->groki_test(6), 6);

is($d->blah_test(7), 7);
is($d->spam(8), 8);
is($d->grok_test(9), 9);
