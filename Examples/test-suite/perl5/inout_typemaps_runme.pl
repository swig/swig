#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('inout_typemaps') }
require_ok('inout_typemaps');

is(inout_typemaps::AddOne1(1), 2);

my ($ret, $out) = inout_typemaps::NonVoidOut(-42);
is($ret, undef);
is($out, 0);
