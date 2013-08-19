use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('typemap_arrays') }
require_ok('typemap_arrays');

is(typemap_arrays::sumA(undef), 60, "Sum is wrong");
