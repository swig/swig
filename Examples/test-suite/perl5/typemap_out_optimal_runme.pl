use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('typemap_out_optimal') }
require_ok('typemap_out_optimal');

$typemap_out_optimal::XX::debug = undef;
my $x = typemap_out_optimal::XX->create();
isa_ok($x, 'typemap_out_optimal::XX');
