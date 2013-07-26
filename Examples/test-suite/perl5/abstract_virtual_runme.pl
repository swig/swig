#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('abstract_virtual') }
require_ok('abstract_virtual');

isnt(abstract_virtual::D->new(), undef);
isnt(abstract_virtual::E->new(), undef);
