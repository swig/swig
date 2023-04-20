use strict;
use warnings;
use Test::More tests => 8;
BEGIN { use_ok('argcargvtest') }
require_ok('argcargvtest');

my $largs = ["hi", "hola", "hello"];
is(argcargvtest::mainc($largs), 3, "test main typemap 1");

my $targs = ["hi", "hola"];
is(argcargvtest::mainv($targs, 1), "hola", "test main typemap 2");

my $errorVal = 0;
my $ret = eval qq(argcargvtest::mainv("hello", 1); \$errorVal = 1;);
is($ret, undef, "test main typemap 3");
is($errorVal, 0, "test main typemap 4");

is(argcargvtest::initializeApp($largs), undef, "test main typemap 5");

ok(1, "done");
