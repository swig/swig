use strict;
use warnings;
use Test::More tests => 10;
BEGIN { use_ok('extend_typedef_class') }
require_ok('extend_typedef_class');

# No namespace
{
  my $s = extend_typedef_class::AClass->new();
  $s->{membervar} = 10;
  is($s->getvar(), 10, 'AClass');
}
{
  my $s = extend_typedef_class::BClass->new();
  $s->{membervar} = 20;
  is($s->getvar(), 20, 'BClass');
}
{
  my $s = extend_typedef_class::CClass->new();
  $s->{membervar} = 30;
  is($s->getvar(), 30, 'CClass');
}
{
  my $s = extend_typedef_class::DClass->new();
  $s->{membervar} = 40;
  is($s->getvar(), 40, 'DClass');
}
# In namespace
{
  my $s = extend_typedef_class::AStruct->new();
  $s->{membervar} = 10;
  is($s->getvar(), 10, 'AStruct');
}
{
  my $s = extend_typedef_class::BStruct->new();
  $s->{membervar} = 20;
  is($s->getvar(), 20, 'BStruct');
}
{
  my $s = extend_typedef_class::CStruct->new();
  $s->{membervar} = 30;
  is($s->getvar(), 30, 'CStruct');
}
{
  my $s = extend_typedef_class::DStruct->new();
  $s->{membervar} = 40;
  is($s->getvar(), 40, 'DStruct');
}
