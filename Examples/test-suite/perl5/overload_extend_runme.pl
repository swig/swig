use strict;
use warnings;
use Test::More tests => 7;
BEGIN { use_ok 'overload_extend' }
require_ok 'overload_extend';

my $f = overload_extend::Foo->new();
is($f->test, 0, 'f.test()');
is($f->test(3), 1, 'f.test(3)');
is($f->test("hello"), 2, 'f.test("hello")');
is($f->test(3, 2), 5, 'f.test(3, 2)');
is($f->test(3.0), 1003, 'f.test(3.0)');
