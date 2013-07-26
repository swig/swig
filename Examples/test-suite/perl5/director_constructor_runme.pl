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

{
    package Wrong;
    use base 'director_constructor::Foo';
    sub doubleit { my($self) = @_;
        # calling this should trigger a type error on attribute
        # assignment
        $self->{a} = {};
    }
    sub test {
        # if c++ calls this, retval copyout should trigger a type error
        return bless {}, 'TotallyBogus';
    }
}

# TODO: these TypeErrors in director classes should be more detailed
my $W = Wrong->new(12);
is eval { $W->doubleit() }, undef;
like $@, qr/TypeError/;
is $W->getit(), 12, 'W.a should be unaffected';

is eval { $W->do_test() }, undef;
like $@, qr/TypeError/;
