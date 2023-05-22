use strict;
use warnings;
use Test::More tests => 17;
BEGIN { use_ok('argcargvtest') }
require_ok('argcargvtest');

my $largs = ["hi", "hola", "hello"];
is(argcargvtest::mainc($largs), 3, "test main typemap 1");

my $targs = ["hi", "hola"];
is(argcargvtest::mainv($targs, 0), "hi", "test main typemap 2a");
is(argcargvtest::mainv($targs, 1), "hola", "test main typemap 2b");
is(argcargvtest::mainv($targs, 2), "<<NULL>>", "test main typemap 2c");

my $errorVal = 0;
my $ret = eval qq(argcargvtest::mainv("hello", 1); \$errorVal = 1;);
is($ret, undef, "test main typemap 3");
is($errorVal, 0, "test main typemap 4");

is(argcargvtest::initializeApp($largs), undef, "test main typemap 5");

# Check that an empty array works.
my @empty_args = ();
is(argcargvtest::mainc(\@empty_args), 0, "test main typemap 6");
is(argcargvtest::mainv(\@empty_args, 0), "<<NULL>>", "test main typemap 6a");

# Check that empty strings are handled.
my @empty_string = ("hello", "", "world");
is(argcargvtest::mainc(\@empty_string), 3, "test main typemap 7");
is(argcargvtest::mainv(\@empty_string, 0), "hello", "test main typemap 8a");
is(argcargvtest::mainv(\@empty_string, 1), "", "test main typemap 8b");
is(argcargvtest::mainv(\@empty_string, 2), "world", "test main typemap 8c");
is(argcargvtest::mainv(\@empty_string, 3), "<<NULL>>", "test main typemap 8d");

ok(1, "done");
