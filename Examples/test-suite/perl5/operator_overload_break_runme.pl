#!/usr/bin/perl -w
use strict;
use Test::More tests => 6;

use operator_overload_break;

# Workaround for 
#   ok( not (expression) , "test description" );
# does not working in older versions of Perl, eg 5.004_04
sub ok_not ($;$) {
    my($test, $name) = @_;
    $test = not $test;
    ok($test, $name);
}

pass("loaded");

my $op = operator_overload_break::Op->new(5);

isa_ok($op, "operator_overload_break::Op");

ok((2 == $op - 3),
   "subtraction");

$op->{k} = 37;

ok((40 == $op + 3),
   "addition");

($op + 3)->Print();

$op->{k} = 22;

ok((10 == (32 - $op)),
   "reversed subtraction");

ok_not((3 == $op),
       'not equal');
