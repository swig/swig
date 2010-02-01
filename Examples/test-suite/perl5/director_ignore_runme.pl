use strict;
use warnings;
use director_ignore;

{
	package DIgnoresDerived;
	use base 'director_ignore::DIgnores';
}
{
	package DAbstractIgnoresDerived;
	use base 'director_ignore::DAbstractIgnores';
}

my $a = DIgnoresDerived->new();

die "Triple failed" if $a->Triple(5) != 15;

my $b = DAbstractIgnoresDerived->new();

die "Quadruple failed" if $b->Quadruple(5) != 20;

