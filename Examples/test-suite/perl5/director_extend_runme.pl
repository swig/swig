# Test case from bug #1506850
#"When threading is enabled, the interpreter will infinitely wait on a mutex the second
#time this type of extended method is called. Attached is an example
#program that waits on the mutex to be unlocked."
use strict;
use warnings;
use director_extend;
# I don't think this test applies to perl, but including for completness

{
	package MyObject;
	use base 'director_extend::SpObject';
	sub getFoo { 123 }
}

my $m = MyObject->new();
die "1st call" if $m->dummy() != 666;
die "2nd call" if $m->dummy() != 666;                   # Locked system
