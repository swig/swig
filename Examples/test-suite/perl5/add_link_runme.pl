use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok 'add_link' }
require_ok 'add_link';

my $f = add_link::Foo->new();
isa_ok $f, 'add_link::Foo';
my $g = $f->blah();
isa_ok $g, 'add_link::Foo';
