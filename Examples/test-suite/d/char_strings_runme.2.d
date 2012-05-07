module char_strings_runme;

import std.conv;
import std.exception;
import std.range;
import char_strings.char_strings;

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

  // get set function
  foreach (i; TEST_RANGE) {
    string ping = OTHERLAND_MSG ~ to!string(i);
    string pong = CharPingPong(ping);
    enforce(ping == pong, "Test PingPong 1 failed.\nExpected:" ~ ping ~ "\nReceived:" ~ pong);
  }

  // variables
  foreach (i; TEST_RANGE) {
    const msg = OTHERLAND_MSG ~ to!string(i);
    global_char = msg;
    enforce(global_char == msg, "Test variables 1 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    const msg = OTHERLAND_MSG ~ to!string(i);
    global_char_array1 = msg;
    enforce(global_char_array1 == msg, "Test variables 2 failed, iteration " ~ to!string(i));
  }

  foreach (i; TEST_RANGE) {
    const msg = OTHERLAND_MSG ~ to!string(i);
    global_char_array2 = msg;
    enforce(global_char_array2 == msg, "Test variables 2 failed, iteration " ~ to!string(i));
  }

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
