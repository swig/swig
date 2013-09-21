use strict;
use warnings;
use Test::More tests => 10;
BEGIN { use_ok('template_typemaps_typedef2') }
require_ok('template_typemaps_typedef2');

{
  my $m1 = template_typemaps_typedef2::MultimapIntA->new();
  my $dummy_pair = $m1->make_dummy_pair();
  my $val = $m1->typemap_test($dummy_pair)->{val};
  is($val, 1234, 'typemaps MultimapIntA');
  is(template_typemaps_typedef2::typedef_test1($dummy_pair)->{val}, 1234, 'typedef_test1');
  is(template_typemaps_typedef2::typedef_test2($dummy_pair)->{val}, 1234, 'typedef_test2');
  is(template_typemaps_typedef2::typedef_test3($dummy_pair)->{val}, 1234, 'typedef_test3');
  is(template_typemaps_typedef2::typedef_test4($dummy_pair)->{val}, 1234, 'typedef_test4');
  is(template_typemaps_typedef2::typedef_test5($dummy_pair)->{val}, 1234, 'typedef_test5');
  is(template_typemaps_typedef2::typedef_test6($dummy_pair)->{val}, 1234, 'typedef_test6');
}

{
  my $m2 = template_typemaps_typedef2::MultimapAInt->new();
  my $dummy_pair = $m2->make_dummy_pair();
  my $val = $m2->typemap_test($dummy_pair);
  is($val, 4321, 'typemaps MultimapAInt');
}
