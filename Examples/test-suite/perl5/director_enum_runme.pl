use strict;
use warnings;
use director_enum;

{
	package MyFoo;
	use base 'director_enum::Foo';
	sub say_hi { my($self, $val) = @_;
		return $val;
	}
}

my $b = director_enum::Foo->new();
my $a = MyFoo->new();

die "RuntimeError" if $a->say_hi($director_enum::hello) !=
	$a->say_hello($director_enum::hi);
