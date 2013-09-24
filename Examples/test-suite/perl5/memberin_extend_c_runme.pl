use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('memberin_extend_c') }
require_ok('memberin_extend_c');

my $t = memberin_extend_c::Person->new();
$t->{name} = 'Fred Bloggs';
is($t->{name}, 'FRED BLOGGS');
