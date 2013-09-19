use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('funcptr_cpp') }
require_ok('funcptr_cpp');

is(funcptr_cpp::call1($funcptr_cpp::ADD_BY_VALUE,     10, 11), 21);
is(funcptr_cpp::call2($funcptr_cpp::ADD_BY_POINTER,   12, 13), 25);
is(funcptr_cpp::call3($funcptr_cpp::ADD_BY_REFERENCE, 14, 15), 29);
