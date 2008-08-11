#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('abstract_typedef2') }
require_ok('abstract_typedef2');

my $e = abstract_typedef2::A_UF->new();
isnt($e, undef);
