use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('li_cdata_cpp') }
require_ok('li_cdata_cpp');

my $s = "ABC\x00abc";
my $m = li_cdata_cpp::malloc(256);
li_cdata_cpp::memmove($m, $s);
my $ss = li_cdata_cpp::cdata($m, 7);
is($ss, "ABC\x00abc", "failed");
