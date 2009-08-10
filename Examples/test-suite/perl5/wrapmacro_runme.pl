#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('wrapmacro') }
require_ok('wrapmacro');

# adapted from ../python/wrapmacro_runme.py

my $a = 2;
my $b = -1;
is(wrapmacro::maximum($a,$b), 2);
is(wrapmacro::maximum($a/7.0, -$b*256), 256);
is(wrapmacro::GUINT16_SWAP_LE_BE_CONSTANT(1), 256);
