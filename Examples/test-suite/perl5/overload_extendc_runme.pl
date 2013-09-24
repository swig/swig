use strict;
use warnings;
use Test::More tests => 10;
BEGIN { use_ok('overload_extendc') }
require_ok('overload_extendc');

my $f = overload_extendc::Foo->new();
is($f->test(3), 1);
is($f->test('hello'), 2);
is($f->test(3.5, 2.5), 3);
is($f->test('hello', 20), 1020);
is($f->test('hello', 20,100), 120);

# C default args
is($f->test($f), 30);
is($f->test($f, 100), 120);
is($f->test($f, 100, 200), 300);

