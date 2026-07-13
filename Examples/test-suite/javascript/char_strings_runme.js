var char_strings = require("char_strings");

var CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible.";
var OTHERLAND_MSG = "Little message from the safe world.";

var assertIsEqual = function(expected, actual) {
  if (expected !== actual) {
    throw new Error("Expected "+expected+", was "+actual);
  }
};

var count = 10;
var i;

// get functions
for (i = 0; i < count; i++) {
  assertIsEqual(CPLUSPLUS_MSG, char_strings.GetCharHeapString());
  char_strings.DeleteCharHeapString();
}

for (i = 0; i < count; i++) {
  assertIsEqual(CPLUSPLUS_MSG, char_strings.GetConstCharProgramCodeString());
  char_strings.DeleteCharHeapString();
}

for (i = 0; i < count; i++) {
  assertIsEqual(CPLUSPLUS_MSG, char_strings.GetCharStaticString());
}

for (i = 0; i < count; i++) {
  assertIsEqual(CPLUSPLUS_MSG, char_strings.GetCharStaticStringFixed());
}

for (i = 0; i < count; i++) {
  assertIsEqual(CPLUSPLUS_MSG, char_strings.GetConstCharStaticStringFixed());
}

// set functions
for (i = 0; i < count; i++) {
  assertIsEqual(true, char_strings.SetCharHeapString(OTHERLAND_MSG + i, i));
}

for (i = 0; i < count; i++) {
  assertIsEqual(true, char_strings.SetCharStaticString(OTHERLAND_MSG + i, i));
}

for (i = 0; i < count; i++) {
  assertIsEqual(true, char_strings.SetCharArrayStaticString(OTHERLAND_MSG + i, i));
}

for (i = 0; i < count; i++) {
  assertIsEqual(true, char_strings.SetConstCharHeapString(OTHERLAND_MSG + i, i));
}

for (i = 0; i < count; i++) {
  assertIsEqual(true, char_strings.SetConstCharStaticString(OTHERLAND_MSG + i, i));
}

for (i = 0; i < count; i++) {
  assertIsEqual(true, char_strings.SetConstCharArrayStaticString(OTHERLAND_MSG + i, i));
}

for (i = 0; i < count; i++) {
  assertIsEqual(true, char_strings.SetCharConstStaticString(OTHERLAND_MSG + i, i));
}

for (i = 0; i < count; i++) {
  assertIsEqual(true, char_strings.SetConstCharConstStaticString(OTHERLAND_MSG + i, i));
}

for (i = 0; i < count; i++) {
  assertIsEqual(true, char_strings.SetConstCharTypedefString(OTHERLAND_MSG + i, i));
}

// get set function
for (i = 0; i < count; i++) {
  var ping1 = OTHERLAND_MSG + i;
  assertIsEqual(ping1, char_strings.CharPingPong(ping1));
}

for (i = 0; i < count; i++) {
  var ping2 = OTHERLAND_MSG + i;
  assertIsEqual(ping2, char_strings.CharArrayPingPong(ping2));
}

// CharArrayDimsPingPong takes a fixed size char[16] parameter. The JavaScript
// char[N] typemap (SWIG_AsCharArray) enforces the buffer size, so the 35 byte
// OTHERLAND_MSG used elsewhere does not fit. A short (< 16 byte) value is used.
for (i = 0; i < count; i++) {
  var ping3 = "pingpong" + i;
  assertIsEqual(ping3, char_strings.CharArrayDimsPingPong(ping3));
}

// variables
for (i = 0; i < count; i++) {
  var expected1 = OTHERLAND_MSG + i;
  char_strings.global_char = expected1;
  assertIsEqual(expected1, char_strings.global_char);
}

// global_char_array1 (char[]) has no setter in the JavaScript module: it is
// exposed read-only (SWIGWARN_TYPEMAP_VARIN_UNDEF), so assigning to it throws
// "Tried to write read-only variable". Only the read is exercised here.
for (i = 0; i < count; i++) {
  assertIsEqual(CPLUSPLUS_MSG, char_strings.global_char_array1);
}
var array1SetVetoed = false;
try {
  char_strings.global_char_array1 = OTHERLAND_MSG + "0";
} catch (e) {
  array1SetVetoed = true;
}
assertIsEqual(true, array1SetVetoed);

for (i = 0; i < count; i++) {
  var expected3 = OTHERLAND_MSG + i;
  char_strings.global_char_array2 = expected3;
  assertIsEqual(expected3, char_strings.global_char_array2);
}

for (i = 0; i < count; i++) {
  assertIsEqual(CPLUSPLUS_MSG, char_strings.global_const_char);
}

for (i = 0; i < count; i++) {
  assertIsEqual(CPLUSPLUS_MSG, char_strings.global_const_char_array1);
}

for (i = 0; i < count; i++) {
  assertIsEqual(CPLUSPLUS_MSG, char_strings.global_const_char_array2);
}

// char *& tests
for (i = 0; i < count; i++) {
  assertIsEqual(CPLUSPLUS_MSG, char_strings.GetCharPointerRef());
}

for (i = 0; i < count; i++) {
  assertIsEqual(true, char_strings.SetCharPointerRef(OTHERLAND_MSG + i, i));
}

for (i = 0; i < count; i++) {
  assertIsEqual(CPLUSPLUS_MSG, char_strings.GetConstCharPointerRef());
}

for (i = 0; i < count; i++) {
  assertIsEqual(true, char_strings.SetConstCharPointerRef(OTHERLAND_MSG + i, i));
}
