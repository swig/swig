use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('arrays_scope') }
require_ok('arrays_scope');

my $obj = arrays_scope::Bar->new();
isa_ok($obj, 'arrays_scope::Bar');
can_ok($obj, 'blah');

$obj->blah($obj->{adata}, $obj->{bdata}, $obj->{cdata});
