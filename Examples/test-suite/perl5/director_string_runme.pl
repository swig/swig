use strict;
use warnings;
use director_string;

{
	package B;
	use base 'director_string::A';
	our $in_first = 0;
	sub get_first { my($self) = @_;
		die "SUPER RESOLVE BAD" if $in_first;
		local $in_first = 1;
		return $self->SUPER::get_first() . " world!";
	}
	our %smem;
	our $in_process_text = 0;
	sub process_text { my($self, $string) = @_;
		die "SUPER RESOLVE BAD" if $in_process_text;
		local $in_process_text = 1;
		$self->SUPER::process_text($string);
		$smem{$self} = "hello";
	}
}

my $b = B->new("hello");

$b->get(0);

die "RuntimeError" if
	$b->get_first() ne "hello world!";

$b->call_process_func();

die "RuntimeError" if $B::smem{$b} ne "hello";
