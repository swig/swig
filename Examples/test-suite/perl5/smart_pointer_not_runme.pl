use strict;
use warnings;
use Test::More tests => 12;
BEGIN { use_ok('smart_pointer_not') }
require_ok('smart_pointer_not');

sub throws_ok(&) {
  eval { $_[0]() };
  isnt($@, undef);
}

my $f = smart_pointer_not::Foo->new();
my $b = smart_pointer_not::Bar->new($f);
my $s = smart_pointer_not::Spam->new($f);
my $g = smart_pointer_not::Grok->new($f);

my $x;

$f->{x} = 37;
throws_ok { $x = $b->{x} };
is($$b->{x}, 37);

$f->{x} = 39;
throws_ok { $x = $s->{x} };
is($$s->{x}, 39);

throws_ok { $x = $g->{x} };

$f->{x} = 41;
throws_ok { $x = $b->getx() };
is($$b->getx(), 41);

$f->{x} = 43;
throws_ok { $x = $s->getx() };
is($$s->getx(), 43);

throws_ok { $x = $g->getx() };
