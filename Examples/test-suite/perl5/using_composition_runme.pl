use strict;
use warnings;
use Test::More tests => 11;
BEGIN { use_ok('using_composition') }
require_ok('using_composition');

my $f = using_composition::FooBar->new();
is($f->blah(3), 3, "FooBar::blah(int)");
is($f->blah(3.5), 3.5, "FooBar::blah(double)");
is($f->blah("hello"), "hello", "FooBar::blah(char *)");

$f = using_composition::FooBar2->new();
is($f->blah(3), 3, "FooBar2::blah(int)");
is($f->blah(3.5), 3.5, "FooBar2::blah(double)");
is($f->blah("hello"), "hello", "FooBar2::blah(char *)");

$f = using_composition::FooBar3->new();
is($f->blah(3), 3, "FooBar3::blah(int)");
is($f->blah(3.5), 3.5, "FooBar3::blah(double)");
is($f->blah("hello"), "hello", "FooBar3::blah(char *)");
