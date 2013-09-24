use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('bloody_hell') }
require_ok('bloody_hell');

is($bloody_hell::kMaxIOCTLSpaceParmsSize, 128);
my $obj = bloody_hell::SM_CHANNEL_IX_DUMP_PARMS->new();
isa_ok($obj, 'bloody_hell::SM_CHANNEL_IX_DUMP_PARMS');
isnt($obj->{data}, undef);
