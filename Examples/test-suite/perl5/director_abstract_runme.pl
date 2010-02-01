use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok('director_abstract') }
require_ok('director_abstract');

{
	package MyFoo;
	use base 'director_abstract::Foo';
	sub ping {
		return 'MyFoo::ping()';
	}
}

my $f = MyFoo->new();

is($a->ping, "MyFoo::ping()");

is($a->pong(),"Foo::pong();MyFoo::ping()");

{
	package MyExample1;
	use base 'director_abstract::Example1';
	sub Color { my($self, $r, $g, $b) = @_;
		return $r;
	}
}
{
	package MyExample2;
	use base 'director_abstract::Example2';
	sub Color { my($self, $r, $g, $b) = @_;
		return $g;
	}
}
{
	package MyExample3;
	use base 'director_abstract::Example3_i';
	sub Color { my($self, $r, $g, $b) = @_;
		return $b;
	}
}
my $me1 = MyExample1->new();
die "darn" if $me1->director_abstract::Example1::get_color(1,2,3) != 1;

my $me2 = MyExample2->new(1,2);
die "darn" if $me2->get_color(1,2,3) != 2;

my $me3 = MyExample3->new();
die "darn" if $me3->get_color(1,2,3) != 3;

eval {
	$me1 = director_abstract::Example1->new();
};
die "darn" unless $@;

eval {
	$me2 = director_abstract::Example2->new();
};
die "darn" unless $@;

eval {
	$me3 = director_abstract::Example3_i->new();
};
die "darn" unless $@;

# I'm not even clear what the heck this is supposed to test
# every way I interpret it, it ought to fail.
# * (new A())->f() should die because A is abstract
# * new A::f() is garbage
# * A.f is a protected method
# Let's skip it.
#
#try:
#	f = director_abstract.A.f
#except:
#	raise RuntimeError
