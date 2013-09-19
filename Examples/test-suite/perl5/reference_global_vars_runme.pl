use strict;
use warnings;
use Test::More tests => 19;
BEGIN { use_ok('reference_global_vars') }
require_ok('reference_global_vars');

# adapted from ../python/reference_global_vars_runme.py

BEGIN {
  # don't try this at home kids... sneaking an import of all symbols
  # from reference_global_vars to main because my fingers are getting
  # sore from qualifying all these names. ;)
  %{*::} = (%{*reference_global_vars::}, %{*::});
}

is(getconstTC()->{num}, 33, 'const class reference variable');

$var_bool = createref_bool(0);
is(value_bool($var_bool), '', 'bool false');

$var_bool = createref_bool(1);
is(value_bool($var_bool), 1, 'bool true');

$var_char = createref_char('w');
is(value_char($var_char), 'w', 'char');

$var_unsigned_char = createref_unsigned_char(10);
is(value_unsigned_char($var_unsigned_char), 10, 'uchar');

$var_signed_char = createref_signed_char(10);
is(value_signed_char($var_signed_char), 10, 'schar');

$var_short = createref_short(10);
is(value_short($var_short), 10, 'short');

$var_unsigned_short = createref_unsigned_short(10);
is(value_unsigned_short($var_unsigned_short), 10, 'ushort');

$var_int = createref_int(10);
is(value_int($var_int), 10, 'int');

$var_unsigned_int = createref_unsigned_int(10);
is(value_unsigned_int($var_unsigned_int), 10, 'uint');

$var_long = createref_long(10);
is(value_long($var_long), 10, 'long');

$var_unsigned_long = createref_unsigned_long(10);
is(value_unsigned_long($var_unsigned_long), 10, 'ulong');

SKIP: {
  no warnings 'portable';
  skip "64 bit int support", 1 unless eval { pack 'q', 1 };
  my $ll = '6FFFFFFFFFFFFFF8';
  $var_long_long = createref_long_long(hex $ll);
  is(value_long_long($var_long_long), hex $ll, 'long long');

  my $ull = 'FFFFFFF2FFFFFFF0';
  $var_unsigned_long_long = createref_unsigned_long_long(hex $ull);
  is(value_unsigned_long_long($var_unsigned_long_long), hex $ull, 'ulong long');
}

$var_float = createref_float(10.5);
is(value_float($var_float), 10.5, 'float');

$var_double = createref_double(10.5);
is(value_double($var_double), 10.5, 'double');

$var_TestClass = createref_TestClass(TestClass->new(20));
is(value_TestClass($var_TestClass)->{num}, 20, 'class reference variable');
