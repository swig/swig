#!/usr/bin/perl -w
use strict;
use Test::More tests => 4;

BEGIN { use_ok('packageoption_a'); }
BEGIN { use_ok('packageoption_b'); }

my $a = CommonPackage::A->new();

isa_ok($a, 'CommonPackage::A');

my $b = CommonPackage::B->new();

isa_ok($b, 'CommonPackage::B');
       
