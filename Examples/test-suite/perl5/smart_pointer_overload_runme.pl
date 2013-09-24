use strict;
use warnings;
use Test::More tests => 8;
BEGIN { use_ok('smart_pointer_overload') }
require_ok('smart_pointer_overload');

my $f = smart_pointer_overload::Foo->new();
my $b = smart_pointer_overload::Bar->new($f);

is($f->test(3), 1);
is($f->test(3.5), 2);
is($f->test('hello'), 3);

is($b->test(3), 1);
is($b->test(3.5), 2);
is($b->test('hello'), 3);


