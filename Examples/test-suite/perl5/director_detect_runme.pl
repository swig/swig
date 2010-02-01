use strict;
use warnings;
use director_detect;

{
	package MyBar;
	use base 'director_detect::Bar';
	# workaround until attributes work.
	our %val;
	sub new { my $class = shift;
		my $val = @_ ? shift : 2;
		my $self = $class->SUPER::new();
		$val{$self} = $val;
		return $self;
	}
	sub get_value { my($self) = @_;
		$val{$self}++;
		return $val{$self};
	}
	sub get_class { my($self) = @_;
		$val{$self}++;
		return director_detect::A->new();
	}
	sub just_do_it { my($self) = @_;
		$val{$self}++;
	}
	sub clone { my($self) = @_;
		MyBar->new($val{$self});
	}
}

my $b = MyBar->new();

my $f = $b->baseclass();

my $v = $f->get_value();
my $a = $f->get_class();
$f->just_do_it();

my $c = $b->clone();
my $vc = $c->get_value();

if( ($v != 3) or ($MyBar::val{$b} != 5) or ($vc != 6) ) {
	die "Bad virtual detection";
}
