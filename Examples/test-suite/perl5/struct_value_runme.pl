use strict;
use warnings;
use Test::More tests => 9;
BEGIN { use_ok('struct_value') }
require_ok('struct_value');

my $b = struct_value::Bar->new();
isa_ok($b, 'struct_value::Bar');

isa_ok($b->{a}, 'struct_value::Foo');
isa_ok($b->{b}, 'struct_value::Foo');

isnt($b->{a}{x}, undef);
isnt($b->{b}{x}, undef);

$b->{a}{x} = 12;
$b->{b}{x} = 34;
is($b->{a}{x}, 12);
is($b->{b}{x}, 34);
