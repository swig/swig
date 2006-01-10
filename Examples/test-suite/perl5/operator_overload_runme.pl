#!/usr/bin/perl -w
use strict;
use Test::More tests => 26;
use operator_overload;

pass("loaded");

# first check all the operators are implemented correctly from pure C++ code
operator_overloadc::Op_sanity_check();

my $op = operator_overload::Op->new();

isa_ok($op, "operator_overload::Op");

my $op2 = operator_overload::Op->new();

isa_ok($op2, "operator_overload::Op");

# operator equal
$op->{i} = 5;
$op2->{i} = 3;

ok(not ($op == $op2), "operator equal: not equal");

$op->{i} = 3;
ok(($op == $op2), "operator equal: equal");

# operator equal
$op->{i} = 5;
$op2->{i} = 3;

ok(($op != $op2), "operator not equal: not equal");

$op->{i} = 3;
ok(not ($op != $op2), "operator not equal: equal");

# stringify operator
$op->{i} = 3;
is("Op(3)", "$op", "operator stringify");

# addition operator
$op->{i} = 3;
$op2->{i} = 3;
my $op3 = $op + $op2;
is($op3->{i}, 6, "operator addition");

# addition assignment operator
$op->{i} = 3;
$op2->{i} = 3;
$op += $op2;
is($op->{i}, 6, "operator additive assignment");

# subtraction operator
$op3->{i} = 6;
$op2->{i} = 3;
$op = $op3 - $op2;
is($op->{i}, 3, "operator subtration");

# subtractive assignment operator
$op->{i} = 6;
$op2->{i} = 3;
$op -= $op2;
is($op->{i}, 3, "operator subtrative assignment");

# multiplication operator
$op->{i} = 3;
$op2->{i} = 3;
$op3 = $op * $op2;
is($op3->{i}, 9, "operator multiplication");

# division operator
$op->{i} = 9;
$op2->{i} = 3;
$op3 = $op / $op2;
is($op3->{i}, 3, "operator division");

# modulus operator
$op->{i} = 8;
$op2->{i} = 3;
$op3 = $op % $op2;
is($op3->{i}, 2, "operator modulus");

# greater than operator
$op->{i} = 8;
$op2->{i} = 3;
ok($op > $op2, "operator greater than");
ok(not ($op2 > $op), "operator greater than");
$op->{i} = 3;
ok(not ($op2 > $op), "operator greater than");
ok(not ($op > $op2), "operator greater than");

# lesser than operator
$op2->{i} = 8;
$op->{i} = 3;
ok($op < $op2, "operator lesser than");
ok(not ($op2 < $op), "operator lesser than");
$op2->{i} = 3;
ok(not ($op2 < $op), "operator lesser than");
ok(not ($op < $op2), "operator lesser than");

# increment operator
$op->{i} = 7;
$op++;
is($op->{i}, 8, "operator increment");

# decrement operator
$op->{i} = 7;
$op--;
is($op->{i}, 6, "operator decrement");

# inverse operator
$op->{i} = 3;
$op2 = -$op;
is($op2->{i}, -3, "operator inverse");

# TODO : {
#   local $TODO = "I can't get Perl to trigger overloaded 'and' and 'or'";

#   # operator and
#   $op->{i} = 0;
#   $op2->{i} = 1;
#   ok(not ($op && $op2), "operator and");
#   $op->{i} = 0;
#   $op2->{i} = 0;
#   ok(not ($op && $op2), "operator and");
#   $op->{i} = 1;
#   $op2->{i} = 1;
#   ok(($op && $op2), "operator and");

#   # operator or
#   $op->{i} = 0;
#   $op2->{i} = 1;
#   ok(($op || $op2), "operator or");
#   $op->{i} = 1;
#   ok(($op || $op2), "operator or");
#   $op->{i} = 0;
#   $op2->{i} = 0;
#   ok(not ($op || $op2), "operator or");
# };

