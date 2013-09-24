use strict;
use warnings;
use Test::More tests => 20;
BEGIN { use_ok('li_attribute') }
require_ok('li_attribute');

my $aa = li_attribute::A->new(1, 2, 3);
is($aa->{a}, 1);
$aa->{a} = 3;
is($aa->{a}, 3);

is($aa->{b}, 2);
$aa->{b} = 5;
is($aa->{b}, 5);

is($aa->{d}, $aa->{b});

is($aa->{c}, 3);
#aa.c = 5
#if aa.c != 3:
#  raise RuntimeError

my $pi = li_attribute::Param_i->new(7);
is($pi->{value}, 7);

$pi->{value} = 3;
is($pi->{value}, 3);

my $b = li_attribute::B->new($aa);

is($b->{a}{c}, 3);

# class/struct attribute with get/set methods using return/pass by reference
my $myFoo = li_attribute::MyFoo->new();
$myFoo->{x} = 8;
my $myClass = li_attribute::MyClass->new();
$myClass->{Foo} = $myFoo;
is($myClass->{Foo}{x}, 8);

# class/struct attribute with get/set methods using return/pass by value
my $myClassVal = li_attribute::MyClassVal->new();
is($myClassVal->{ReadWriteFoo}{x}, -1);
is($myClassVal->{ReadOnlyFoo}{x}, -1);
$myClassVal->{ReadWriteFoo} = $myFoo;
is($myClassVal->{ReadWriteFoo}{x}, 8);
is($myClassVal->{ReadOnlyFoo}{x}, 8);

# string attribute with get/set methods using return/pass by value
my $myStringyClass = li_attribute::MyStringyClass->new('initial string');
is($myStringyClass->{ReadWriteString}, 'initial string');
is($myStringyClass->{ReadOnlyString}, 'initial string');
$myStringyClass->{ReadWriteString} = 'changed string';
is($myStringyClass->{ReadWriteString}, 'changed string');
is($myStringyClass->{ReadOnlyString}, 'changed string');
