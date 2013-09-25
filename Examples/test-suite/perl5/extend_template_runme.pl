use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('extend_template') }
require_ok('extend_template');

my $f = extend_template::Foo_0->new();
is($f->test1(37), 37, 'Foo_0.test1()');
is($f->test2(42), 42, 'Foo_0.test2()');
