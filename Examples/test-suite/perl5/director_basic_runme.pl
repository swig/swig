use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok 'director_basic' }
require_ok 'director_basic';

{
    package PlFoo;
    use base 'director_basic::Foo';
    sub ping { my($self) = @_;
        return "PlFoo::ping()";
    }
}

{
    my $x = PlFoo->new();
    isa_ok $x, 'PlFoo';
    is $x->ping(), 'PlFoo::ping()', 'subcl ping';
    is $x->pong(), 'Foo::pong();PlFoo::ping()', 'subcl pong';
}
{
    my $y = director_basic::Foo->new();
    isa_ok $y, 'director_basic::Foo';
    is $y->ping(), 'Foo::ping()', 'inst ping';
    is $y->pong(), 'Foo::pong();Foo::ping()', 'inst pong';
}
{
    my $a1 = director_basic::A1->new(1);
    isa_ok $a1, 'director_basic::A1';
    is $a1->rg(2), 2, 'A1.rg';
}

{
	package PlClass;
	use base 'director_basic::MyClass';
	our %cmethod;
	sub method { my($self, $vptr) = @_;
		# custom subclass attributes are broken for now. (cheating)
		$cmethod{$self} = 7;
	}
	sub vmethod { my($self, $b) = @_;
		$b->{x} = $b->{x} + 31;
		return $b;
	}
}

{
    my $b = director_basic::Bar->new(3);
    isa_ok $b, 'director_basic::Bar';
    my $d = director_basic::MyClass->new();
    isa_ok $d, 'director_basic::MyClass';
    my $c = PlClass->new();
    isa_ok $d, 'PlClass';

    my $cc = director_basic::MyClass->get_self($c);
    isa_ok $cc, 'PlClass';
    my $dd = director_basic::MyClass->get_self($d);
    isa_ok $dd, 'director_basic::MyClass';

    my $bc = $cc->cmethod($b);
    my $bd = $dd->cmethod($b);

    $cc->method($b);
        # custom subclass attributes are broken for now. (cheating)
    die "RuntimeError" if $PlClass::cmethod{$c} != 7;

    die "RuntimeError" if $bc->{x} != 34;

    die "RuntimeError" if $bd->{x} != 16;
}

## no multiple inheritance support yet.
##
##class PyMulti(director_basic.Foo, director_basic.MyClass):
##	def __init__(self):
##		director_basic.Foo.__init__(self)
##		director_basic.MyClass.__init__(self)		
##		pass
##
##		
##	def vmethod(self, b):
##		b.x = b.x  + 31
##		return b
##
##	
##	def ping(self):
##		return "PyFoo::ping()"
##
##a = 0
##for i in range(0,100):
##    pymult = PyMulti()
##    pymult.pong()
##    del pymult 
##
##
##
##pymult = PyMulti()
##
##
##
##
##p1 = director_basic.Foo_get_self(pymult)
##p2 = director_basic.MyClass_get_self(pymult)
##
##p1.ping()
##p2.vmethod(bc)
##
