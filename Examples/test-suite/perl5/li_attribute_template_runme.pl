use strict;
use warnings;
use Test::More tests => 22;
BEGIN { use_ok('li_attribute_template') }
require_ok('li_attribute_template');

my $chell = li_attribute_template::Cintint->new(1, 2, 3);

## Testing primitive by value attribute
is($chell->{a}, 1);

$chell->{a} = 3;
is($chell->{a}, 3);

## Testing primitive by ref attribute
is($chell->{b}, 2);

$chell->{b} = 5;
is($chell->{b}, 5);

## Testing string
$chell->{str} = 'abc';
is($chell->{str}, 'abc');

# Testing class by value
is($chell->{d}{value}, 1);

$chell->{d} = li_attribute_template::Foo->new(2);
is($chell->{d}{value}, 2);

# Testing class by reference
is($chell->{e}{value}, 2);

$chell->{e} = li_attribute_template::Foo->new(3);
is($chell->{e}{value}, 3);

$chell->{e}{value} = 4;
is($chell->{e}{value}, 4);

# Testing moderately complex template by value
is($chell->{f}{first}, 1);
is($chell->{f}{second}, 2);

my $pair = li_attribute_template::pair_intint->new(3, 4);
$chell->{f} = $pair;
is($chell->{f}{first}, 3);
is($chell->{f}{second}, 4);

# Testing moderately complex template by ref
is($chell->{g}{first}, 2);
is($chell->{g}{second}, 3);

$pair = li_attribute_template::pair_intint->new(4, 5);
$chell->{g} = $pair;
is($chell->{g}{first}, 4);
is($chell->{g}{second}, 5);

$chell->{g}{first} = 6;
$chell->{g}{second} = 7;
is($chell->{g}{first}, 6);
is($chell->{g}{second}, 7);
