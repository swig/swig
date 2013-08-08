use strict;
use warnings;
use Test::More tests => 14;
BEGIN { use_ok('using_inherit') }
require_ok('using_inherit');

my $b = using_inherit::Bar->new();
is($b->test(3), 3, "Bar::test(int)");
is($b->test(3.5), 3.5, "Bar::test(double)");

$b = using_inherit::Bar2->new();
is($b->test(3), 6,"Bar2::test(int)");
is($b->test(3.5), 7.0, "Bar2::test(double)");

$b = using_inherit::Bar3->new();
is($b->test(3), 6, "Bar3::test(int)");
is($b->test(3.5), 7.0, "Bar3::test(double)");

$b = using_inherit::Bar4->new();
is($b->test(3), 6,"Bar4::test(int)");
is($b->test(3.5), 7.0, "Bar4::test(double)");

$b = using_inherit::Fred1->new();
is($b->test(3), 3, "Fred1::test(int)");
is($b->test(3.5), 7.0, "Fred1::test(double)");

$b = using_inherit::Fred2->new();
is($b->test(3), 3, "Fred2::test(int)");
is($b->test(3.5), 7.0, "Fred2::test(double)");
