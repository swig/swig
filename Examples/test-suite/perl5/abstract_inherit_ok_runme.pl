#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('abstract_inherit_ok') }
require_ok('abstract_inherit_ok');

my $o = abstract_inherit_ok::Spam->new();
is($o->blah(), 0);
