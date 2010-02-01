use strict;
use warnings;
use director_constructor;

{
	package Test;
	use base 'director_constructor::Foo';
	sub doubleit { my($self) = @_;
		$self->{a} *= 2;
	}
	sub test { 3 }
}
my $a = Test->new(5);

die "RuntimeError" if $a->getit != 5;
die "RuntimeError" if $a->do_test != 3;

$a->doubleit();

die "RuntimeError" if $a->getit != 10;
