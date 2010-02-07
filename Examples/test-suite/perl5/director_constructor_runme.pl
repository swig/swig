use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok 'director_constructor' }
require_ok 'director_constructor';

{
	package Test;
	use base 'director_constructor::Foo';
	sub doubleit { my($self) = @_;
		$self->{a} *= 2;
	}
	sub test { 3 }
}
my $A = Test->new(5);
isa_ok $A, 'Test';
is $A->getit, 5;
is $A->do_test, 3;

$A->doubleit();

is $A->getit, 10;
