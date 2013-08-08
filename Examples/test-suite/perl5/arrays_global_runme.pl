use strict;
use warnings;
use Test::More tests => 13;
BEGIN { use_ok('arrays_global') }
require_ok('arrays_global');

#$arrays_global::array_i = $arrays_global::array_const_i;

is($arrays_global::BeginString_FIX44a, "FIX.a.a");
is($arrays_global::BeginString_FIX44b, "FIX.b.b");
is($arrays_global::BeginString_FIX44c, "FIX.c.c");
is($arrays_global::BeginString_FIX44d, "FIX.d.d");
is($arrays_global::BeginString_FIX44e, "FIX.e.e");
is($arrays_global::BeginString_FIX44f, "FIX.f.f");

is(arrays_global::test_a("hello","hi","chello","chi"), "hi");
is(arrays_global::test_a(6), 6);
is(arrays_global::test_b("1234567","hi"), "1234567");
is(arrays_global::test_b(8), 8);

isa_ok($arrays_global::hitMat_val, 'arrays_global::Material');
