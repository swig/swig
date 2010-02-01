use strict;
use warnings;
use director_wombat;

{
	package director_wombat_Foo_integers_derived;
	use base 'director_wombat::Foo_integers';
	sub meth { my($self, $param) = @_;
		return $param + 2;
	}
}
{
	package director_wombat_Foo_integers_derived_2;
	use base 'director_wombat::Foo_integers';
}
{
	package director_wombat_Bar_derived_1;
	use base 'director_wombat::Bar';
	sub foo_meth_ref { my($self, $foo_obj, $param) = @_;
		die "foo_obj in foo_meth_ref is not director_wombat_Foo_integers_derived_2"
			unless $foo_obj->isa('director_wombat_Foo_integers_derived_2');
	}
	sub foo_meth_ptr { my($self, $foo_obj, $param) = @_;
		die "foo_obj in foo_meth_ptr is not director_wombat_Foo_integers_derived_2"
			unless $foo_obj->isa('director_wombat_Foo_integers_derived_2');
	}
	sub foo_meth_val { my($self, $foo_obj, $param) = @_;
		die "foo_obj in foo_meth_val is not director_wombat_Foo_integers_derived_2"
			unless $foo_obj->isa('director_wombat_Foo_integers_derived_2');
	}
}

my $b = director_wombat::Bar->new();
my $a = $b->meth();
die "failure" if $a->meth(49) != 49;

$a = director_wombat_Foo_integers_derived->new();
die "failure" if $a->meth(62) != 62 + 2;

$a = director_wombat_Foo_integers_derived_2->new();
die "failure" if $a->meth(37) != 37;

$b = director_wombat_Bar_derived_1->new();
$b->foo_meth_ref($a, 0);
$b->foo_meth_ptr($a, 1);
$b->foo_meth_val($a, 2);

