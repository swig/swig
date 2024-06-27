use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('char_binary_rev_len') }
require_ok('char_binary_rev_len');

my $t = char_binary_rev_len::Test->new();

is($t->strlen('hile'), 4, "string typemap");

is($t->strlen("hil\0"), 4, "string typemap");
