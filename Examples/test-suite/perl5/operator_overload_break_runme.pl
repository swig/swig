#!/usr/bin/perl -w
use strict;
use Test::More tests => 9;

use operator_overload_break;

pass("loaded");

my $op = operator_overload_break::Op->new(5);

isa_ok($op, "operator_overload_break::Op");

ok((2 == $op - 3),
   "subtraction");

$op->{k} = 37;

ok((40 == $op + 3),
   "addition");

$op->{k} = 22;

ok((10 == (32 - $op)),
   "reversed subtraction");

ok(not(3 == $op),
       'not equal');

$op->{k} = 3;

++$op;

ok(($op == 4),
   "pre-increment operator");

$op++;

ok(($op == 5),
   "post-increment operator");

my $op2 = ++$op;

$op2 = $op++;

ok(($op == 7) and ($op2 == 7),
   "multiple post-increments");
