use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok 'newobject1' }
require_ok 'newobject1';

{
    my $f = newobject1::Foo->makeFoo();
    isa_ok $f, 'newobject1::Foo';
    is(newobject1::Foo->fooCount(), 1);
    undef $f;
    is(newobject1::Foo->fooCount(), 0);
}
