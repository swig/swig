use strict;
use warnings;
use director_primitives;

{
	package PerlDerived;
	use base 'director_primitives::Base';
	sub NoParmsMethod {
	}
	sub BoolMethod { my($self, $x) = @_;
		return $x;
	}
	sub IntMethod { my($self, $x) = @_;
		return $x;
	}
	sub UIntMethod { my($self, $x) = @_;
		return $x;
	}
	sub FloatMethod { my($self, $x) = @_;
		return $x;
	}
	sub CharPtrMethod { my($self, $x) = @_;
		return $x;
	}
	sub ConstCharPtrMethod { my($self, $x) = @_;
		return $x;
	}
	sub EnumMethod { my($self, $x) = @_;
		return $x;
	}
	sub ManyParmsMethod {
	}
}

my $myCaller = director_primitives::Caller->new();

{
	my $myBase = director_primitives::Base->new(100.0);
	makeCalls($myCaller, $myBase);
}
{
	my $myBase = director_primitives::Derived->new(200.0);
	makeCalls($myCaller, $myBase);
}
{
	my $myBase = PerlDerived->new(300.0);
	makeCalls($myCaller, $myBase);
}

sub makeCalls { my($myCaller, $myBase) = @_;
	$myCaller->set($myBase);
	$myCaller->NoParmsMethodCall();
	die "failed" unless $myCaller->BoolMethodCall(1);
	die "failed" if $myCaller->BoolMethodCall(0);
	die "failed" if $myCaller->IntMethodCall(-123) != -123;
	die "failed" if $myCaller->UIntMethodCall(123) != 123;
	die "failed" if $myCaller->FloatMethodCall(-123 / 128) != -0.9609375;
	die "failed" if $myCaller->CharPtrMethodCall("test string") ne "test string";
	die "failed" if $myCaller->ConstCharPtrMethodCall("another string") ne "another string";
	die "failed" if $myCaller->EnumMethodCall($director_primitives::HShadowHard) != $director_primitives::HShadowHard;
	$myCaller->ManyParmsMethodCall(1, -123, 123, 123.456, "test string", "another string", $director_primitives::HShadowHard);
	$myCaller->NotOverriddenMethodCall();
	$myCaller->reset();
}

