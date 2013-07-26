use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok 'director_ignore' }
require_ok 'director_ignore';

{
	package DIgnoresDerived;
	use base 'director_ignore::DIgnores';
}
{
	package DAbstractIgnoresDerived;
	use base 'director_ignore::DAbstractIgnores';
}

my $a = DIgnoresDerived->new();
isa_ok $a, 'DIgnoresDerived';
is $a->Triple(5), 15;

my $b = DAbstractIgnoresDerived->new();
isa_ok $b, 'DAbstractIgnoresDerived';
is $b->Quadruple(5), 20;

