use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('struct_rename') }
require_ok('struct_rename');

ok(!struct_rename::Foo->isa('struct_rename::Foo'), 'Foo class not created');
ok(struct_rename::Bar->isa('struct_rename::Bar'), 'Bar class created');
my $b = struct_rename::Bar->new();
isa_ok($b, 'struct_rename::Bar');
isnt($b->{x}, undef, 'b.x defined');
