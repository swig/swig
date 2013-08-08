use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('constructor_copy') }
require_ok('constructor_copy');

my $f1 = constructor_copy::Foo1->new(3);
my $f11 = constructor_copy::Foo1->new($f1);

is($f1->{x}, $f11->{x});


my $f8 = constructor_copy::Foo8->new();
is(eval { constructor_copy::Foo81->new($f8); 1 }, undef);


my $bi = constructor_copy::Bari->new(5);
my $bc = constructor_copy::Bari->new($bi);
is($bi->{x}, $bc->{x});
    
my $bd = constructor_copy::Bard->new(5);
is(eval { constructor_copy::Bard->new($bd); 1 }, undef);

