exec("swigtest.start", -1);

CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible.";
OTHERLAND_MSG = "Little message from the safe world.";

count = 5;

// get functions
for i = 0:count-1
  checkequal(GetCharHeapString(), CPLUSPLUS_MSG, "GetCharHeapString()");
  DeleteCharHeapString();
end

for i = 0:count-1
  checkequal(GetConstCharProgramCodeString(), CPLUSPLUS_MSG, "GetConstCharProgramCodeString()");
  DeleteCharHeapString();
end

for i = 0:count-1
  checkequal(GetCharStaticString(), CPLUSPLUS_MSG, "GetCharStaticString()");
end

for i = 0:count-1
  checkequal(GetCharStaticStringFixed(), CPLUSPLUS_MSG, "GetCharStaticStringFixed()");
end

for i = 0:count-1
  checkequal(GetConstCharStaticStringFixed(), CPLUSPLUS_MSG, "GetConstCharStaticStringFixed()");
end

// set functions
for i = 0:count-1
  checkequal(SetCharHeapString(OTHERLAND_MSG + string(i), i), %t, "SetCharHeapString()");
end

for i = 0:count-1
  checkequal(SetCharStaticString(OTHERLAND_MSG + string(i), i), %t, "SetCharStaticString()");
end

for i = 0:count-1
  checkequal(SetCharArrayStaticString(OTHERLAND_MSG + string(i), i), %t, "SetCharArrayStaticString()");
end

for i = 0:count-1
  checkequal(SetConstCharHeapString(OTHERLAND_MSG + string(i), i), %t, "SetConstCharHeapString()");
end

for i = 0:count-1
  checkequal(SetConstCharStaticString(OTHERLAND_MSG + string(i), i), %t, "SetConstCharStaticString()");
end

for i = 0:count-1
  checkequal(SetConstCharArrayStaticString(OTHERLAND_MSG + string(i), i), %t, "SetConstCharArrayStaticString()");
end

for i = 0:count-1
  checkequal(SetCharConstStaticString(OTHERLAND_MSG + string(i), i), %t, "SetCharConstStaticString()");
end

for i = 0:count-1
  checkequal(SetConstCharConstStaticString(OTHERLAND_MSG + string(i), i), %t, "SetConstCharConstStaticString()");
end

for i = 0:count-1
  checkequal(SetConstCharTypedefString(OTHERLAND_MSG + string(i), i), %t, "SetConstCharTypedefString()");
end

// get set function (ping pong)
for i = 0:count-1
  ping = OTHERLAND_MSG + string(i);
  checkequal(CharPingPong(ping), ping, "CharPingPong()");
end

for i = 0:count-1
  ping = OTHERLAND_MSG + string(i);
  checkequal(CharArrayPingPong(ping), ping, "CharArrayPingPong()");
end

// CharArrayDimsPingPong takes a fixed char[16] buffer, so the string must fit in 16 bytes
for i = 0:count-1
  ping = "PingPong" + string(i);
  checkequal(CharArrayDimsPingPong(ping), ping, "CharArrayDimsPingPong()");
end

// variables
for i = 0:count-1
  expected = OTHERLAND_MSG + string(i);
  global_char_set(expected);
  checkequal(global_char_get(), expected, "global_char");
end

// global_char_array1 is char[] with no dimension => read-only in Scilab (VARIN typemap
// undefined, see %warnfilter in char_strings.i). It retains its initial value.
for i = 0:count-1
  checkequal(global_char_array1_get(), CPLUSPLUS_MSG, "global_char_array1");
end

for i = 0:count-1
  expected = OTHERLAND_MSG + string(i);
  global_char_array2_set(expected);
  checkequal(global_char_array2_get(), expected, "global_char_array2");
end

for i = 0:count-1
  checkequal(global_const_char_get(), CPLUSPLUS_MSG, "global_const_char");
end

for i = 0:count-1
  checkequal(global_const_char_array1_get(), CPLUSPLUS_MSG, "global_const_char_array1");
end

for i = 0:count-1
  checkequal(global_const_char_array2_get(), CPLUSPLUS_MSG, "global_const_char_array2");
end

// char *& tests
for i = 0:count-1
  checkequal(GetCharPointerRef(), CPLUSPLUS_MSG, "GetCharPointerRef()");
end

for i = 0:count-1
  checkequal(SetCharPointerRef(OTHERLAND_MSG + string(i), i), %t, "SetCharPointerRef()");
end

for i = 0:count-1
  checkequal(GetConstCharPointerRef(), CPLUSPLUS_MSG, "GetConstCharPointerRef()");
end

for i = 0:count-1
  checkequal(SetConstCharPointerRef(OTHERLAND_MSG + string(i), i), %t, "SetConstCharPointerRef()");
end

exec("swigtest.quit", -1);
