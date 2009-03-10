use strict;
use warnings;
use Test::More tests => 9;
BEGIN { use_ok 'disown' }
require_ok 'disown';

my $k;
{
    my $a = disown::A->new();
    is(exists $disown::A::OWNER{$a->this()}, 1, 'A initial ownership');
    $a->DISOWN();
    is(exists $disown::A::OWNER{$a->this()}, '', 'A release');
    $a->ACQUIRE();
    is(exists $disown::A::OWNER{$a->this()}, 1, 'A take ownership');
    $k = $a->this();
}
is(exists $disown::A::OWNER{$k}, '', 'swig drops A');
{
    my $a = disown::A->new();
    my $b = disown::B->new();
    $k = $b->this();
    is(exists $disown::B::OWNER{$k}, 1, 'B initial ownership');
    is($b->acquire($a), 5, 'return 5');
    is(exists $disown::A::OWNER{$a->this()}, '', 'B took A');
}
