use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('char_strings') }
require_ok('char_strings');

my $val1 = "100";
is(char_strings::CharPingPong($val1), "100", 'cstr1');

my $val2 = "greetings";
is(char_strings::CharPingPong($val2), "greetings", 'cstr2');

