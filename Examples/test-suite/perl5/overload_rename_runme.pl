use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('overload_rename') }
require_ok('overload_rename');

isa_ok(overload_rename::Foo->new(1), 'overload_rename::Foo');
isa_ok(overload_rename::Foo->new(1,1), 'overload_rename::Foo');
isa_ok(overload_rename::Foo->Foo_int(1,1), 'overload_rename::Foo');
isa_ok(overload_rename::Foo->Foo_int(1,1,1), 'overload_rename::Foo');
