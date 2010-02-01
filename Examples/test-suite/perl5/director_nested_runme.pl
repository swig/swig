use strict;
use warnings;
use director_nested;

{
	package A;
	use base 'director_nested::FooBar_int';
	sub do_step { 'A::do_step;' }
	sub get_value { 'A::get_value' }
}

my $a = A->new();
die "Bad A virtual resolution" if
	$a->step() ne "Bar::step;Foo::advance;Bar::do_advance;A::do_step;";

{
	package B;
	use base 'director_nested::FooBar_int';
	sub do_advance { my($self) = @_;
		return "B::do_advance;" . $self->do_step();
	}
	sub do_step { "B::do_step;" }
	sub get_value { 1 }
}

my $b = B->new();

die "Bad B virtual resolution" if
	$b->step() ne "Bar::step;Foo::advance;B::do_advance;B::do_step;";

{
	package C;
	use base 'director_nested::FooBar_int';
	our $in_do_advance = 0;
	sub do_advance { my($self) = @_;
		# found a case where upcall didn't happen right in a perl space
		# SUPER:: call.
		die "SUPERCALL RESOLVE FAILURE" if $in_do_advance;
		local $in_do_advance = 1;
		return "C::do_advance;" .
			$self->SUPER::do_advance();
	}
	sub do_step { "C::do_step;" }
	sub get_value { 2 }
	sub get_name { my($self) = @_;
		return $self->director_nested::FooBar_int::get_name() . " hello";
	}
}

my $cc = C->new();
my $c = director_nested::FooBar_int->get_self($cc);
$c->advance();

die "RuntimeError" if $c->get_name() ne "FooBar::get_name hello";

die "RuntimeError" if $c->name() ne "FooBar::get_name hello";
