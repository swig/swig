use strict;
use warnings;
use Test::More tests => 10;
BEGIN { use_ok('template_typemaps_typedef') }
require_ok('template_typemaps_typedef');

my $m1 = template_typemaps_typedef::MultimapIntA->new();

my $dummy_pair = $m1->make_dummy_pair();
my $val = $m1->typemap_test($dummy_pair)->{val};
is($val, 1234, "typemaps not working");

my $m2 = template_typemaps_typedef::MultimapAInt->new();
$dummy_pair = $m2->make_dummy_pair();
$val = $m2->typemap_test($dummy_pair);
is($val, 4321, "typemaps not working");

is(template_typemaps_typedef::typedef_test1($dummy_pair)->{val}, 1234, "typedef_test1 not working");
is(template_typemaps_typedef::typedef_test2($dummy_pair)->{val}, 1234, "typedef_test2 not working");
is(template_typemaps_typedef::typedef_test3($dummy_pair)->{val}, 1234, "typedef_test3 not working");
is(template_typemaps_typedef::typedef_test4($dummy_pair)->{val}, 1234, "typedef_test4 not working");
is(template_typemaps_typedef::typedef_test5($dummy_pair)->{val}, 1234, "typedef_test5 not working");
is(template_typemaps_typedef::typedef_test6($dummy_pair)->{val}, 1234, "typedef_test6 not working");
