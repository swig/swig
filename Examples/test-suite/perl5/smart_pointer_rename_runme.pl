use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('smart_pointer_rename') }
require_ok('smart_pointer_rename');

my $f = smart_pointer_rename::Foo->new();
my $b = smart_pointer_rename::Bar->new($f);

is($b->test(), 3);
is($b->ftest1(1), 1);
is($b->ftest2(2, 3), 2);
