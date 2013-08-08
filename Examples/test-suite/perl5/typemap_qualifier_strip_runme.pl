use strict;
use warnings;
use Test::More tests => 18;
BEGIN { use_ok('typemap_qualifier_strip') }
require_ok('typemap_qualifier_strip');

my $val = typemap_qualifier_strip::create_int(111);
is(typemap_qualifier_strip::testA1($val), 1234);
is(typemap_qualifier_strip::testA2($val), 1234);
is(typemap_qualifier_strip::testA3($val), 1234);
is(typemap_qualifier_strip::testA4($val), 1234);
is(typemap_qualifier_strip::testB1($val), 111);
is(typemap_qualifier_strip::testB2($val), 111);
is(typemap_qualifier_strip::testB3($val), 111);
is(typemap_qualifier_strip::testB4($val), 111);
is(typemap_qualifier_strip::testC1($val), 5678);
is(typemap_qualifier_strip::testC2($val), 111);
is(typemap_qualifier_strip::testC3($val), 5678);
is(typemap_qualifier_strip::testC4($val), 111);
is(typemap_qualifier_strip::testD1($val), 111);
is(typemap_qualifier_strip::testD2($val), 3456);
is(typemap_qualifier_strip::testD3($val), 111);
is(typemap_qualifier_strip::testD4($val), 111);
