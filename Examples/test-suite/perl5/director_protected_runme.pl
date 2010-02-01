use strict;
use warnings;
use director_protected;

{
	package FooBar;
	use base 'director_protected::Bar';
	sub ping { 'FooBar::ping();' }
}
{
	package FooBar2;
	use base 'director_protected::Bar';
	sub ping { 'FooBar2::ping();' }
	sub pang { 'FooBar2::pang();' }
}

my $b  = director_protected::Bar->new();
my $f  = $b->create();
my $fb = FooBar->new();
my $fb2 = FooBar2->new();

my $s = $fb->used();
die "RuntimeError" if
	$s ne "Foo::pang();Bar::pong();Foo::pong();FooBar::ping();";

eval {
	$s = $fb->used();
	die if $s ne "Foo::pang();Bar::pong();Foo::pong();FooBar::ping();";
};
die "bad FooBar::used" if $@;

eval {
	$s = $fb2->used();
	die if $s ne "FooBar2::pang();Bar::pong();Foo::pong();FooBar2::ping();";
};
die "bad FooBar2::used" if $@;

eval {
	$s = $b->pong();
	die if $s ne "Bar::pong();Foo::pong();Bar::ping();";
};
die "bad Bar::pong" if $@;

eval {
	$s = $f->pong();
	die if $s ne "Bar::pong();Foo::pong();Bar::ping();";
};
die "bad Foo::pong $@" if $@;

eval {
	$s = $fb->pong();
	die if $s ne "Bar::pong();Foo::pong();FooBar::ping();";
};
die "bad FooBar::pong" if $@;

my $protected = 1;
eval {
	$b->ping();
	$protected = 0;
};
die "Boo::ping is protected" unless $protected;
  
$protected = 1;
eval {
	$f->ping();
	$protected = 0;
};
die "Foo::ping is protected" unless $protected;

$protected = 1;
eval {
	$f->pang();
	$protected = 0;
};
die "FooBar::pang is protected" unless $protected;
