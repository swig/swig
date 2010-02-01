use strict;
use warnings;
use director_unroll;

{
	package MyFoo;
	use base 'director_unroll::Foo';
	sub ping { "MyFoo::ping()" }
}

$a = MyFoo->new();

$b = director_unroll::Bar->new();

$b->set($a);
my $c = $b->get();

die "RuntimeError" unless
	$a->this ne $c->this;
