use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('cpp_enum') }
require_ok('cpp_enum');

my $f = cpp_enum::Foo->new();

is($f->{hola}, $cpp_enum::Foo::Hello);

$f->{hola} = $cpp_enum::Foo::Hi;
is($f->{hola}, $cpp_enum::Foo::Hi);

$f->{hola} = $cpp_enum::Foo::Hello;
is($f->{hola}, $cpp_enum::Foo::Hello);

$cpp_enum::hi = $cpp_enum::Hello;

is($cpp_enum::hi, $cpp_enum::Hello);
