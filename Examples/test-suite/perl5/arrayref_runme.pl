use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('arrayref') }
require_ok('arrayref');

can_ok('arrayref', 'foo');
can_ok('arrayref', 'bar');
