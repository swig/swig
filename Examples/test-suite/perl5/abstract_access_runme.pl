#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('abstract_access') }
require_ok('abstract_access');

# adapted from ../python/abstract_access.py

my $d = abstract_access::D->new();
is($d->do_x(), 1);

