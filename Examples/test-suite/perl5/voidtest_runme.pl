use strict;
use warnings;
use Test::More tests => 10;
BEGIN { use_ok('voidtest') }
require_ok('voidtest');

can_ok('voidtest', 'globalfunc');
voidtest::globalfunc();
can_ok('voidtest::Foo', 'new', 'staticmemberfunc');
my $f = voidtest::Foo->new();
can_ok($f, 'memberfunc');
is($f->memberfunc(), undef);

my $v1 = voidtest::vfunc1($f);
my $v2 = voidtest::vfunc2($f);
is($v1, $v2);

my $v3 = voidtest::vfunc3($v1);
my $v4 = voidtest::vfunc4($f);
is($v3, $v4);
is($v3->this, $f->this);
{ local $TODO = "not sure this should work, but maybe void* is special";
is($v1, $v4);
}
