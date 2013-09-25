use strict;
use warnings;
use Test::More tests => 69;
BEGIN { use_ok('extend_default') }
require_ok('extend_default');

for my $class (qw(
    extend_default::Before
    extend_default::After
    extend_default::OverBefore
    extend_default::OverAfter
)) {
  my($name) = $class =~ /::(.*?)$/;
  can_ok($class, 'AddedStaticMethod');
  is($class->AddedStaticMethod(), -2.0, "$name.AddedStaticMethod()");
  is($class->AddedStaticMethod(3), 2.0, "$name.AddedStaticMethod(i)");
  is($class->AddedStaticMethod(3, 1.5), 4.5, "$name.AddedStaticMethod(i, d)");
  my $obj = $class->new();
  isa_ok($obj, $class);
  is($obj->{d}, -1.0, "$name.d");
  is($obj->{i}, -1, "$name.i");
  is($class->new(3)->{i}, 3, "$name(i).i");
  is($class->new(3, 7.5)->{d}, 7.5, "$name(i, d).d");
  can_ok($obj, 'AddedMethod');
  is($obj->AddedMethod(), -2.0, "$name.AddedMethod()");
  is($obj->AddedMethod(7), 6.0, "$name.AddedMethod(i)");
  is($obj->AddedMethod(7, 4.5), 11.5, "$name.AddedMethod(i, d)");
}

{
  my $obj = extend_default::Override->new();
  isa_ok($obj, 'extend_default::Override');
  is($obj->over(10), 100, 'Override.over(i)');
  is($obj->overload(11), 121, 'Override.overload(i)');
  is($obj->overload(), -10, 'Override.overload()');
}

{
  is(extend_default::Base->static_method(), undef, 'Base.static_method()');
  my $obj = extend_default::Base->new();
  isa_ok($obj, 'extend_default::Base');
  is($obj->realvirtual(), undef, 'Base.realvirtual()');
  is($obj->virtualmethod(), undef, 'Base.virtualmethod()');
  is($obj->nonvirtual(), undef, 'Base.nonvirtual()');
}
{
  is(extend_default::Derived->static_method(), undef, 'Base.static_method()');
  my $obj = extend_default::Derived->new();
  isa_ok($obj, 'extend_default::Derived');
  isa_ok($obj, 'extend_default::Base');
  is($obj->realvirtual(), undef, 'Derived.realvirtual()');
  is($obj->virtualmethod(), undef, 'Derived.virtualmethod()');
  is($obj->nonvirtual(), undef, 'Derived.nonvirtual()');
}
