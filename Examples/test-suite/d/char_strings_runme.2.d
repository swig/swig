module char_strings_runme;

import std.conv;
import std.exception;
import std.range;
import char_strings.char_strings;
import char_strings.CharArrayOne;

enum CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible.";
enum OTHERLAND_MSG = "Little message from the safe world.";
enum TEST_RANGE = iota(0, 10000);

void main() {
  // get functions
  foreach (i; TEST_RANGE) {
    enforce(GetCharHeapString() == CPLUSPLUS_MSG, "Test char get 1 failed, iteration " ~ to!string(i));
    DeleteCharHeapString();
  }

  foreach (i; TEST_RANGE) {
    enforce(GetConstCharProgramCodeString() == CPLUSPLUS_MSG, "Test char get 2 failed, iteration " ~ to!string(i));
    DeleteCharHeapString();
  }

  foreach (i; TEST_RANGE) {
    enforce(GetCharStaticString() == CPLUSPLUS_MSG, "Test char get 3 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(GetCharStaticStringFixed() == CPLUSPLUS_MSG, "Test char get 4 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(GetConstCharStaticStringFixed() == CPLUSPLUS_MSG, "Test char get 5 failed, iteration " ~ to!string(i));
  }

  // set functions
  foreach (i; TEST_RANGE) {
    enforce(SetCharHeapString(OTHERLAND_MSG ~ to!string(i), i), "Test char set 1 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(SetCharStaticString(OTHERLAND_MSG ~ to!string(i), i), "Test char set 2 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(SetCharArrayStaticString(OTHERLAND_MSG ~ to!string(i), i), "Test char set 3 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(SetConstCharHeapString(OTHERLAND_MSG ~ to!string(i), i), "Test char set 4 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(SetConstCharStaticString(OTHERLAND_MSG ~ to!string(i), i), "Test char set 5 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(SetConstCharArrayStaticString(OTHERLAND_MSG ~ to!string(i), i), "Test char set 6 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(SetCharConstStaticString(OTHERLAND_MSG ~ to!string(i), i), "Test char set 7 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(SetConstCharConstStaticString(OTHERLAND_MSG ~ to!string(i), i), "Test char set 8 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(SetConstCharTypedefString(OTHERLAND_MSG ~ to!string(i), i), "Test char set 9 failed, iteration " ~ to!string(i));
  }

  // get set function
  foreach (i; TEST_RANGE) {
    string ping = OTHERLAND_MSG ~ to!string(i);
    string pong = CharPingPong(ping);
    enforce(ping == pong, "Test PingPong 1 failed.\nExpected:" ~ ping ~ "\nReceived:" ~ pong);
  }

  foreach (i; TEST_RANGE) {
    string ping = OTHERLAND_MSG ~ to!string(i);
    string pong = CharArrayPingPong(ping);
    enforce(ping == pong, "Test PingPong 2 failed.\nExpected:" ~ ping ~ "\nReceived:" ~ pong);
  }

  foreach (i; TEST_RANGE) {
    string ping = "Ping" ~ to!string(i); // char[16] buffer, keep short enough to fit
    string pong = CharArrayDimsPingPong(ping);
    enforce(ping == pong, "Test PingPong 3 failed.\nExpected:" ~ ping ~ "\nReceived:" ~ pong);
  }

  enforce(CharArrayDimsLength("Ping") == 4, "Test CharArrayDimsLength failed");
  enforce(CharArrayDimsLength("0123456789abcde") == 15, "Test CharArrayDimsLength failed");
  enforce(collectException(CharArrayDimsLength("0123456789abcdef")) !is null, "Test CharArrayDimsLength overlong string failed");

  // variables
  foreach (i; TEST_RANGE) {
    const msg = OTHERLAND_MSG ~ to!string(i);
    global_char = msg;
    enforce(global_char == msg, "Test variables 1 failed, iteration " ~ to!string(i));
  }

  // global_char_array1 is a char[] with no size, so it is read only
  static assert(!__traits(compiles, global_char_array1 = "x"));
  enforce(global_char_array1 == CPLUSPLUS_MSG, "Test variables 2 failed");

  foreach (i; TEST_RANGE) {
    const msg = OTHERLAND_MSG ~ to!string(i);
    global_char_array2 = msg;
    enforce(global_char_array2 == msg, "Test variables 2 failed, iteration " ~ to!string(i));
  }

  enforce(collectException(global_char_array2 = CPLUSPLUS_MSG ~ CPLUSPLUS_MSG) !is null, "Test variables 3 overlong string failed");
  enforce(char_array_no_nul.full == "abcd" && char_array_no_nul.after == "XYZ", "Test full char array failed");
  global_char_one = "a";
  auto one = new CharArrayOne();
  one.one = "b";
  enforce(global_char_one == "a" && one.one == "b", "Test char[1] failed");
  enforce(CharArrayPingPong(null) is null && CharArrayDimsPingPong(null) is null, "Test char array null failed");
  enforce(collectException(char_array_null.four = null) !is null, "Test char array member set to null failed");
  enforce(collectException(global_char_array_null = null) !is null, "Test char array global set to null failed");
  enforce(char_array_null.four == "qqq" && global_char_array_null == "qqq", "Test char array set to null changed it");

  foreach (i; TEST_RANGE) {
    enforce(global_const_char == CPLUSPLUS_MSG, "Test variables 4 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(global_const_char_array1 == CPLUSPLUS_MSG, "Test variables 5 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(global_const_char_array2 == CPLUSPLUS_MSG, "Test variables 6 failed, iteration " ~ to!string(i));
  }

  // char *& tests
  foreach (i; TEST_RANGE) {
    enforce(GetCharPointerRef() == CPLUSPLUS_MSG, "Test char pointer ref get failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(SetCharPointerRef(OTHERLAND_MSG ~ to!string(i), i), "Test char pointer ref set failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(GetConstCharPointerRef() == CPLUSPLUS_MSG, "Test const char pointer ref get failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    enforce(SetConstCharPointerRef(OTHERLAND_MSG ~ to!string(i), i), "Test const char pointer ref set failed, iteration " ~ to!string(i));
  }
}
