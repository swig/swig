use strict;
use warnings;
use director_frob;

my $foo = director_frob::Bravo->new();

my $s = $foo->abs_method();

die "RuntimeError: $s" if $s ne "Bravo::abs_method()";
