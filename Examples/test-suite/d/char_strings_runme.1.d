module char_strings_runme;

import tango.text.convert.Integer;
import char_strings.char_strings;

const char[] CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible.";
const char[] OTHERLAND_MSG = "Little message from the safe world.";

void main() {
  const uint count = 10000;
  uint i = 0;

  // get functions
  for (i=0; i<count; i++) {
    char[] str = GetCharHeapString();
    if (str != CPLUSPLUS_MSG)
      throw new Exception("Test char get 1 failed, iteration " ~ toString(i));
    DeleteCharHeapString();
  }

  for (i=0; i<count; i++) {
    char[] str = GetConstCharProgramCodeString();
    if (str != CPLUSPLUS_MSG)
      throw new Exception("Test char get 2 failed, iteration " ~ toString(i));
    DeleteCharHeapString();
  }

  for (i=0; i<count; i++) {
    char[] str = GetCharStaticString();
    if (str != CPLUSPLUS_MSG)
      throw new Exception("Test char get 3 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    char[] str = GetCharStaticStringFixed();
    if (str != CPLUSPLUS_MSG)
      throw new Exception("Test char get 4 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    char[] str = GetConstCharStaticStringFixed();
    if (str != CPLUSPLUS_MSG)
      throw new Exception("Test char get 5 failed, iteration " ~ toString(i));
  }

  // set functions
  for (i=0; i<count; i++) {
    if (!SetCharHeapString(OTHERLAND_MSG ~ toString(i), i))
      throw new Exception("Test char set 1 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (!SetCharStaticString(OTHERLAND_MSG ~ toString(i), i))
      throw new Exception("Test char set 2 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (!SetCharArrayStaticString(OTHERLAND_MSG ~ toString(i), i))
      throw new Exception("Test char set 3 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (!SetConstCharHeapString(OTHERLAND_MSG ~ toString(i), i))
      throw new Exception("Test char set 4 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (!SetConstCharStaticString(OTHERLAND_MSG ~ toString(i), i))
      throw new Exception("Test char set 5 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (!SetConstCharArrayStaticString(OTHERLAND_MSG ~ toString(i), i))
      throw new Exception("Test char set 6 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (!SetCharConstStaticString(OTHERLAND_MSG ~ toString(i), i))
      throw new Exception("Test char set 7 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (!SetConstCharConstStaticString(OTHERLAND_MSG ~ toString(i), i))
      throw new Exception("Test char set 8 failed, iteration " ~ toString(i));
  }

  // get set function
  for (i=0; i<count*10; i++) {
    char[] ping = OTHERLAND_MSG ~ toString(i);
    char[] pong = CharPingPong(ping);
    if (ping != pong)
      throw new Exception("Test PingPong 1 failed.\nExpected:" ~ ping ~ "\nReceived:" ~ pong);
  }

  // variables
  for (i=0; i<count; i++) {
    global_char = OTHERLAND_MSG ~ toString(i);
    if (global_char != OTHERLAND_MSG ~ toString(i))
      throw new Exception("Test variables 1 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    global_char_array1 = OTHERLAND_MSG ~ toString(i);
    if (global_char_array1 != OTHERLAND_MSG ~ toString(i))
      throw new Exception("Test variables 2 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    global_char_array2 = OTHERLAND_MSG ~ toString(i);
    if (global_char_array2 != OTHERLAND_MSG ~ toString(i))
      throw new Exception("Test variables 3 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (global_const_char != CPLUSPLUS_MSG)
      throw new Exception("Test variables 4 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (global_const_char_array1 != CPLUSPLUS_MSG)
      throw new Exception("Test variables 5 failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (global_const_char_array2 != CPLUSPLUS_MSG)
      throw new Exception("Test variables 6 failed, iteration " ~ toString(i));
  }

  // char *& tests
  for (i=0; i<count; i++) {
    char[] str = GetCharPointerRef();
    if (str != CPLUSPLUS_MSG)
      throw new Exception("Test char pointer ref get failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (!SetCharPointerRef(OTHERLAND_MSG ~ toString(i), i))
      throw new Exception("Test char pointer ref set failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    char[] str = GetConstCharPointerRef();
    if (str != CPLUSPLUS_MSG)
      throw new Exception("Test const char pointer ref get failed, iteration " ~ toString(i));
  }

  for (i=0; i<count; i++) {
    if (!SetConstCharPointerRef(OTHERLAND_MSG ~ toString(i), i))
      throw new Exception("Test const char pointer ref set failed, iteration " ~ toString(i));
  }
}
