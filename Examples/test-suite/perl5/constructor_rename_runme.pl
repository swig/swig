use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('constructor_rename') }
require_ok('constructor_rename');

is(constructor_rename::Foo->can('new'), undef);
isa_ok(constructor_rename::Foo->RenamedConstructor(), 'constructor_rename::Foo');
