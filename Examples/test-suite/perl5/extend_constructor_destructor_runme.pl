use strict;
use warnings;
use Test::More tests => 16;
BEGIN { use_ok('extend_constructor_destructor') }
require_ok('extend_constructor_destructor');

{
  my $a = extend_constructor_destructor::AStruct->new(10);
  is($extend_constructor_destructor::globalVar, 10);
  my $b = extend_constructor_destructor::BStruct->new(20);
  is($extend_constructor_destructor::globalVar, 20);
  my $c = extend_constructor_destructor::CStruct->new(30);
  is($extend_constructor_destructor::globalVar, 30);
  my $d = extend_constructor_destructor::DStruct->new(40);
  is($extend_constructor_destructor::globalVar, 40);
  my $e = extend_constructor_destructor::EStruct->new(50);
  is($extend_constructor_destructor::globalVar, 50);
  my $f = extend_constructor_destructor::FStruct->new(60);
  is($extend_constructor_destructor::globalVar, 60);
  my $g = extend_constructor_destructor::GStruct->new(70);
  is($extend_constructor_destructor::globalVar, 70);
  undef $a;
  is($extend_constructor_destructor::globalVar, -10);
  undef $b;
  is($extend_constructor_destructor::globalVar, -20);
  undef $c;
  is($extend_constructor_destructor::globalVar, -30);
  undef $d;
  is($extend_constructor_destructor::globalVar, -40);
  undef $e;
  is($extend_constructor_destructor::globalVar, -50);
  undef $f;
  is($extend_constructor_destructor::globalVar, -60);
  undef $g;
  is($extend_constructor_destructor::globalVar, -70);
}
