#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('charptr_fragment') }
require_ok('charptr_fragment');

is(charptr_fragment::getCharBuf(), "hello", "getCharBuf");
is(charptr_fragment::getBinaryCharBuf(), "hello", "getBinaryCharBuf");
