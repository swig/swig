use strict;
use warnings;
use Test::More tests => 15;
BEGIN { use_ok('inherit') }
require_ok('inherit');

my $a = inherit::CBase->new();
is($a->isa('inherit::CBase'), 1, 'base');

my $b = inherit::CDerived->new();
is($b->isa('inherit::CDerived'), 1, 'sanity');
is($b->isa('inherit::CBase'), 1, 'basic c++ inheritance');
is($b->Foo(), "CBase::Foo", "method check");

{
	package PDerived1;
	use base 'inherit::CBase';
}
my $c = PDerived1->new();
is($c->isa('inherit::CBase'), 1, 'interpreter inheritance');
is($c->isa('PDerived1'), 1, 'sanity');

{
	package PDerived2;
	use base 'inherit::CDerived';
}
my $d = PDerived2->new();
is($d->isa('inherit::CBase'), 1);
is($d->isa('inherit::CDerived'), 1);
is($d->isa('PDerived2'), 1);

{
	package PDerived3;
	use base 'PDerived2';
}
my $e = PDerived3->new();
is($e->isa('inherit::CBase'), 1);
is($e->isa('inherit::CDerived'), 1);
is($e->isa('PDerived2'), 1);
is($e->isa('PDerived3'), 1);
