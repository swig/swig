#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('abstract_typedef') }
require_ok('abstract_typedef');

my $e = abstract_typedef::Engine->new();
isnt($e, undef);
my $a = abstract_typedef::A->new();
isnt($a, undef);
is($a->write($e), 1);
