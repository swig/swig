use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok 'profiletest' }
require_ok 'profiletest';
my $a = profiletest::A->new();
my $b = profiletest::B->new();

for (my $i = 0; $i < 100000; $i++) {
    $a = $b->fn($a);
}

