use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('extend_template_ns') }
require_ok('extend_template_ns');

my $f = extend_template_ns::Foo_One->new();
is($f->test1(37), 37, 'Foo_One.test1()');
is($f->test2(42), 42, 'Foo_One.test2()');
