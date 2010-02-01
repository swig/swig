use strict;
use warnings;
use director_exception;

{
	package MyFoo;
	use base 'director_exception::Foo';
	sub ping {
		die "MyFoo::ping() EXCEPTION";
	}
}
{
	package MyFoo2;
	use base 'director_exception::Foo';
	sub ping {
		# error should return a string
		return sub { 1 };
	}
}

my $ok = 0;

my $a = MyFoo->new();
my $b = director_exception::launder($a);

eval { $b->pong() };
die "should have thrown" unless $@;
die "error content not preserved" unless $@ =~ /\bMyFoo::ping\(\) EXCEPTION\b/;

$ok = 0;

$a = MyFoo2->new();
$b = director_exception::launder($a);

eval { $b->pong() };
die "should have thrown" unless $@;
die "error content not preserved" unless $@ =~ /\bstd::string\b/;

eval { die director_exception::Exception2->new() };

eval { die director_exception::Exception1->new() };
