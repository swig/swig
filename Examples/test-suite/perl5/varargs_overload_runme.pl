use strict;
use warnings;
use Test::More tests => 11;
BEGIN { use_ok('varargs_overload') }
require_ok('varargs_overload');

is(varargs_overload::vararg_over1("Hello"), "Hello");
is(varargs_overload::vararg_over1(2), "2");
is(varargs_overload::vararg_over2("Hello"), "Hello");
is(varargs_overload::vararg_over2(2, 2.2), "2 2.2");
is(varargs_overload::vararg_over3("Hello"), "Hello");
is(varargs_overload::vararg_over3(2, 2.2, "hey"), "2 2.2 hey");
is(varargs_overload::vararg_over4("Hello"), "Hello");
is(varargs_overload::vararg_over4(123), "123");
is(varargs_overload::vararg_over4("Hello", 123), "Hello");
