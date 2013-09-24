use strict;
use warnings;
use Test::More tests => 15;
BEGIN { use_ok('allprotected_not') }
require_ok('allprotected_not');

my $class = 'allprotected_not::AllProtectedNot';

my $obj = $class->new();
isa_ok($obj, $class);

eval { $obj->PublicMethod() };
is($@, '', 'obj.PublicMethod()');
eval { $class->PublicMethod() };
isnt($@, '', 'class.PublicMethod()');

eval { $obj->ProtectedMethod() };
isnt($@, '', 'obj.ProtectedMethod()');
eval { $class->ProtectedMethod() };
isnt($@, '', 'class.ProtectedMethod()');

eval { $obj->StaticNonVirtualProtectedMethod() };
isnt($@, '', 'obj.StaticNonVirtualProtectedMethod()');
eval { $class->StaticNonVirtualProtectedMethod() };
isnt($@, '', 'class.StaticNonVirtualProtectedMethod()');

eval { $obj->NonVirtualProtectedMethod() };
isnt($@, '', 'obj.NonVirtualProtectedMethod()');
eval { $class->NonVirtualProtectedMethod() };
isnt($@, '', 'class.NonVirtualProtectedMethod()');

eval { $a = $obj->{ProtectedVariable} };
isnt($@, '', 'obj.ProtectedVariable');
{
  no warnings 'once';
  is($allprotected_not::AllProtectedNot::ProtectedVariable, undef, 'class.ProtectedVariable');
}

eval { $a = $obj->{StaticProtectedVariable} };
isnt($@, '', 'obj.StaticProtectedVariable');
{
  no warnings 'once';
  is($allprotected_not::AllProtectedNot::StaticProtectedVariable, undef, 'class.StaticProtectedVariable');
}
