#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('typedef_funcptr') }
require_ok('typedef_funcptr');

can_ok('typedef_funcptr', 'do_op');
is(typedef_funcptr::do_op(9, 5, $typedef_funcptr::subf), 4, 'subf');
is(typedef_funcptr::do_op(9, 5, $typedef_funcptr::addf), 14, 'addf');
