use strict;
use warnings;
use Test::More tests => 38;
BEGIN { use_ok 'imports_a' }
require_ok 'imports_a';
BEGIN { use_ok 'imports_b' }
require_ok 'imports_b';

my $x = imports_a::A->new();
isa_ok($x, 'imports_a::A');
my $y = imports_b::B->new();
isa_ok($y, 'imports_b::B'); 
my $z = imports_b::C->new();
isa_ok($z, 'imports_b::C'); 

is($y->imports_a::A::hello(), undef, 'cross module dispatch');

# baseline enum checks
is(imports_a::global_test($imports_a::globalenum1),
        $imports_a::globalenum1, 'baseline ge1');
is(imports_a::global_test($imports_a::globalenum2),
        $imports_a::globalenum2, 'baseline ge2');

is($x->global_virtual_test($imports_a::globalenum1),
        $imports_a::globalenum1, 'baseling A gvt1');
is($x->global_virtual_test($imports_a::globalenum2),
        $imports_a::globalenum2, 'baseline A gvt2');
is($x->member_virtual_test($imports_a::A::memberenum1),
        $imports_a::A::memberenum1, 'baseline A mvt1');
is($x->member_virtual_test($imports_a::A::memberenum2),
        $imports_a::A::memberenum2, 'baseline A mvt2');

is($y->global_virtual_test($imports_a::globalenum1),
        $imports_a::globalenum2, 'baseline B gvt1');
is($y->global_virtual_test($imports_a::globalenum2),
        $imports_a::globalenum2, 'baseline B gvt2');
is($y->member_virtual_test($imports_a::A::memberenum1),
        $imports_a::A::memberenum2, 'baseline B mvt1');
is($y->member_virtual_test($imports_a::A::memberenum2),
        $imports_a::A::memberenum2, 'baseline B mvt2');


my $x1 = $z->get_a($x);
isa_ok($x1, 'imports_a::A');
is($x1->global_virtual_test($imports_a::globalenum1),
        $imports_a::globalenum1, 'z.get_a(x).gvt1');
is($x1->global_virtual_test($imports_a::globalenum2),
        $imports_a::globalenum2, 'z.get_a(x).gvt2');
is($x1->member_virtual_test($imports_a::A::memberenum1),
        $imports_a::A::memberenum1, 'z.get_a(x).mvt1');
is($x1->member_virtual_test($imports_a::A::memberenum2),
        $imports_a::A::memberenum2, 'z.get_a(x).mvt2');

my $x2 = $z->get_a_type($x);
isa_ok($x2, 'imports_a::A');
is($x2->global_virtual_test($imports_a::globalenum1),
        $imports_a::globalenum1, 'z.get_a_type(x).gvt1');
is($x2->global_virtual_test($imports_a::globalenum2),
        $imports_a::globalenum2, 'z.get_a_type(x).gvt2');
is($x2->member_virtual_test($imports_a::A::memberenum1),
        $imports_a::A::memberenum1, 'z.get_a_type(x).mvt1');
is($x2->member_virtual_test($imports_a::A::memberenum2),
        $imports_a::A::memberenum2, 'z.get_a_type(x).mvt2');

my $y1 = $z->get_a($y);
isa_ok($y1, 'imports_a::A');
is($y1->global_virtual_test($imports_a::globalenum1),
        $imports_a::globalenum2, 'z.get_a(y).gvt1');
is($y1->global_virtual_test($imports_a::globalenum2),
        $imports_a::globalenum2, 'z.get_a(y).gvt2');
is($y1->member_virtual_test($imports_a::A::memberenum1),
        $imports_a::A::memberenum2, 'z.get_a(y).mvt1');
is($y1->member_virtual_test($imports_a::A::memberenum2),
        $imports_a::A::memberenum2, 'z.get_a(y).mvt2');

my $y2 = $z->get_a_type($y);
isa_ok($y1, 'imports_a::A');
is($y2->global_virtual_test($imports_a::globalenum1),
        $imports_a::globalenum2, 'z.get_a_type(y).gvt1');
is($y2->global_virtual_test($imports_a::globalenum2),
        $imports_a::globalenum2, 'z.get_a_type(y).gvt2');
is($y2->member_virtual_test($imports_a::A::memberenum1),
        $imports_a::A::memberenum2, 'z.get_a_type(y).mvt1');
is($y2->member_virtual_test($imports_a::A::memberenum2),
        $imports_a::A::memberenum2, 'z.get_a_type(y).mvt2');
