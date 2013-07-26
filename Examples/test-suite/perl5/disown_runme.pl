use strict;
use warnings;
use Test::More tests => 8;
BEGIN { use_ok 'disown' }
require_ok 'disown';

my $a = disown::A->new();
isa_ok $a, 'disown::A';
is($a->_swig_own, 1);
my $b = disown::B->new();
isa_ok $b, 'disown::B';
is($b->_swig_own, 1);
is($b->acquire($a), 5);
is($a->_swig_own, '');


