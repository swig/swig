use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('li_cdata') }
require_ok('li_cdata');

my $s = 'ABC abc';
my $m = li_cdata::malloc(256);
li_cdata::memmove($m, $s);
my $ss = li_cdata::cdata($m, 7);
is($ss, 'ABC abc');
