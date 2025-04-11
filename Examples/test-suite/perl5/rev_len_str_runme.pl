use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('rev_len_str') }
require_ok('rev_len_str');

my $t = rev_len_str::Test->new();

is($t->strlen('hile'), 4, "string typemap");

is($t->strlen("hil\0"), 4, "string typemap");
