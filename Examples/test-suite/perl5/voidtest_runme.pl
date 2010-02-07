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
is($v3->_swig_this, $f->_swig_this);
TODO: {
  # in general the same pointer cast to different types probably needs
  # to be distinct.  However a void* may be special
   local $TODO = "not sure we want this to succeed";
is($v1, $v4);
}
