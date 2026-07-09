use strict;
use warnings;
use Test::More tests => 29;
BEGIN { use_ok('char_strings') }
require_ok('char_strings');

my $CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible.";
my $OTHERLAND_MSG = "Little message from the safe world.";

# get functions
is(char_strings::GetCharHeapString(), $CPLUSPLUS_MSG, 'char get 1');
char_strings::DeleteCharHeapString();

is(char_strings::GetConstCharProgramCodeString(), $CPLUSPLUS_MSG, 'char get 2');

is(char_strings::GetCharStaticString(), $CPLUSPLUS_MSG, 'char get 3');

is(char_strings::GetCharStaticStringFixed(), $CPLUSPLUS_MSG, 'char get 4');

is(char_strings::GetConstCharStaticStringFixed(), $CPLUSPLUS_MSG, 'char get 5');

# set functions - Set(OTHERLAND_MSG . number, number) must return true
ok(char_strings::SetCharHeapString($OTHERLAND_MSG . 1, 1), 'char set 1');
ok(char_strings::SetCharStaticString($OTHERLAND_MSG . 2, 2), 'char set 2');
ok(char_strings::SetCharArrayStaticString($OTHERLAND_MSG . 3, 3), 'char set 3');
ok(char_strings::SetConstCharHeapString($OTHERLAND_MSG . 4, 4), 'char set 4');
ok(char_strings::SetConstCharStaticString($OTHERLAND_MSG . 5, 5), 'char set 5');
ok(char_strings::SetConstCharArrayStaticString($OTHERLAND_MSG . 6, 6), 'char set 6');
ok(char_strings::SetCharConstStaticString($OTHERLAND_MSG . 7, 7), 'char set 7');
ok(char_strings::SetConstCharConstStaticString($OTHERLAND_MSG . 8, 8), 'char set 8');
ok(char_strings::SetConstCharTypedefString($OTHERLAND_MSG . 9, 9), 'char set 9');

# get set functions (ping pong round trip)
{
  my $ping = $OTHERLAND_MSG . 11;
  is(char_strings::CharPingPong($ping), $ping, 'PingPong 1');
}
{
  my $ping = $OTHERLAND_MSG . 12;
  is(char_strings::CharArrayPingPong($ping), $ping, 'PingPong 2');
}
# CharArrayDimsPingPong takes char[16], so the string must fit in 15 chars + nul
{
  my $ping = "PingPong 13";
  is(char_strings::CharArrayDimsPingPong($ping), $ping, 'PingPong 3');
}

# variables
{
  my $expected = $OTHERLAND_MSG . 21;
  $char_strings::global_char = $expected;
  is($char_strings::global_char, $expected, 'variables 1 (global_char set+read)');
}
# global_char_array1 is read-only in Perl (char[] has no varin typemap), so only read it
is($char_strings::global_char_array1, $CPLUSPLUS_MSG, 'variables 2 (global_char_array1 read)');
{
  my $expected = $OTHERLAND_MSG . 23;
  $char_strings::global_char_array2 = $expected;
  is($char_strings::global_char_array2, $expected, 'variables 3 (global_char_array2 set+read)');
}
is($char_strings::global_const_char, $CPLUSPLUS_MSG, 'variables 4 (global_const_char read-only)');
is($char_strings::global_const_char_array1, $CPLUSPLUS_MSG, 'variables 5 (global_const_char_array1 read-only)');
is($char_strings::global_const_char_array2, $CPLUSPLUS_MSG, 'variables 6 (global_const_char_array2 read-only)');

# char *& tests
is(char_strings::GetCharPointerRef(), $CPLUSPLUS_MSG, 'char *& get 1');
ok(char_strings::SetCharPointerRef($OTHERLAND_MSG . 31, 31), 'char *& set 2');
is(char_strings::GetConstCharPointerRef(), $CPLUSPLUS_MSG, 'char *& get 3');
ok(char_strings::SetConstCharPointerRef($OTHERLAND_MSG . 33, 33), 'char *& set 4');
