use strict;
use warnings;
use Test::More tests => 2;
BEGIN { use_ok('allowexcept') }
require_ok('allowexcept');

# not much to test here, it's about exception handling, but nothing throws.
# at least we can verify that the library is really loadable.
