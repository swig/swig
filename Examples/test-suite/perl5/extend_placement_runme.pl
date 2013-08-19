use strict;
use warnings;
use Test::More tests => 12;
BEGIN { use_ok('extend_placement') }
require_ok('extend_placement');

my $foo;
$foo = extend_placement::Foo->new();
isa_ok($foo, 'extend_placement::Foo');
$foo = extend_placement::Foo->new(1);
isa_ok($foo, 'extend_placement::Foo');
$foo = extend_placement::Foo->new(1, 1);
isa_ok($foo, 'extend_placement::Foo');
$foo->spam();
$foo->spam("hello");
$foo->spam(1);
$foo->spam(1, 1);
$foo->spam(1, 1, 1);
$foo->spam(extend_placement::Foo->new());
$foo->spam(extend_placement::Foo->new(), 1.0);

my $bar;
$bar = extend_placement::Bar->new();
isa_ok($bar, 'extend_placement::Bar');
$bar = extend_placement::Bar->new(1);
isa_ok($bar, 'extend_placement::Bar');
$bar->spam();
$bar->spam("hello");
$bar->spam(1);
$bar->spam(1, 1);
$bar->spam(1, 1, 1);
$bar->spam(extend_placement::Bar->new());
$bar->spam(extend_placement::Bar->new(), 1.0);

$foo = extend_placement::FooTi->new();
isa_ok($foo, 'extend_placement::FooTi');
$foo = extend_placement::FooTi->new(1);
isa_ok($foo, 'extend_placement::FooTi');
$foo = extend_placement::FooTi->new(1, 1);
isa_ok($foo, 'extend_placement::FooTi');
$foo->spam();
$foo->spam("hello");
$foo->spam(1);
$foo->spam(1,1);
$foo->spam(1,1,1);
$foo->spam(extend_placement::Foo->new());
$foo->spam(extend_placement::Foo->new(), 1.0);

$bar = extend_placement::BarTi->new();
isa_ok($bar, 'extend_placement::BarTi');
$bar = extend_placement::BarTi->new(1);
isa_ok($bar, 'extend_placement::BarTi');
$bar->spam();
$bar->spam("hello");
$bar->spam(1);
$bar->spam(1,1);
$bar->spam(1,1,1);
$bar->spam(extend_placement::Bar->new());
$bar->spam(extend_placement::Bar->new(), 1.0);
