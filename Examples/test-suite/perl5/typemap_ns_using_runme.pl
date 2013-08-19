use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('typemap_ns_using') }
require_ok('typemap_ns_using');

is(typemap_ns_using::spam(37), 37);
