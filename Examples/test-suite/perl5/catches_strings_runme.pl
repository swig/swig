use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('catches_strings') }
require_ok('catches_strings');

eval {
  catches_strings::StringsThrower::charstring();
};
like($@, qr/\bcharstring message/, "Should have thrown an exception");

eval {
  catches_strings::StringsThrower::stdstring();
};
like($@, qr/\bstdstring message/, "Should have thrown an exception");
