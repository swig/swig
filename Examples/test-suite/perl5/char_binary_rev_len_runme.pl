use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('char_binary_rev_len') }
require_ok('char_binary_rev_len');

my $t = char_binary_rev_len::Test->new();

is($t->strlen('hile'), 4, "bad multi-arg typemap 1");

is($t->strlen("hil\0"), 4, "bad multi-arg typemap 2");

my $t2 = char_binary_rev_len::Test->new('hile');
is($t2->getisize(), 4, "bad multi-arg typemap 3");
is($t2->strlen("hil\0a"), 5, "bad multi-arg typemap 4");
