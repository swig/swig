# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

char_strings

CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible.";
OTHERLAND_MSG = "Little message from the safe world.";

count = 5;

# get functions
for i = 0:count-1
  if (!strcmp(char_strings.GetCharHeapString(), CPLUSPLUS_MSG))
    error("Test char get 1 failed");
  endif
  char_strings.DeleteCharHeapString();
endfor

for i = 0:count-1
  if (!strcmp(char_strings.GetConstCharProgramCodeString(), CPLUSPLUS_MSG))
    error("Test char get 2 failed");
  endif
  char_strings.DeleteCharHeapString();
endfor

for i = 0:count-1
  if (!strcmp(char_strings.GetCharStaticString(), CPLUSPLUS_MSG))
    error("Test char get 3 failed");
  endif
endfor

for i = 0:count-1
  if (!strcmp(char_strings.GetCharStaticStringFixed(), CPLUSPLUS_MSG))
    error("Test char get 4 failed");
  endif
endfor

for i = 0:count-1
  if (!strcmp(char_strings.GetConstCharStaticStringFixed(), CPLUSPLUS_MSG))
    error("Test char get 5 failed");
  endif
endfor

# set functions
for i = 0:count-1
  if (!char_strings.SetCharHeapString([OTHERLAND_MSG num2str(i)], i))
    error("Test char set 1 failed");
  endif
endfor

for i = 0:count-1
  if (!char_strings.SetCharStaticString([OTHERLAND_MSG num2str(i)], i))
    error("Test char set 2 failed");
  endif
endfor

for i = 0:count-1
  if (!char_strings.SetCharArrayStaticString([OTHERLAND_MSG num2str(i)], i))
    error("Test char set 3 failed");
  endif
endfor

for i = 0:count-1
  if (!char_strings.SetConstCharHeapString([OTHERLAND_MSG num2str(i)], i))
    error("Test char set 4 failed");
  endif
endfor

for i = 0:count-1
  if (!char_strings.SetConstCharStaticString([OTHERLAND_MSG num2str(i)], i))
    error("Test char set 5 failed");
  endif
endfor

for i = 0:count-1
  if (!char_strings.SetConstCharArrayStaticString([OTHERLAND_MSG num2str(i)], i))
    error("Test char set 6 failed");
  endif
endfor

for i = 0:count-1
  if (!char_strings.SetCharConstStaticString([OTHERLAND_MSG num2str(i)], i))
    error("Test char set 7 failed");
  endif
endfor

for i = 0:count-1
  if (!char_strings.SetConstCharConstStaticString([OTHERLAND_MSG num2str(i)], i))
    error("Test char set 8 failed");
  endif
endfor

for i = 0:count-1
  if (!char_strings.SetConstCharTypedefString([OTHERLAND_MSG num2str(i)], i))
    error("Test char set 9 failed");
  endif
endfor

# get set function (ping pong)
for i = 0:count-1
  ping = [OTHERLAND_MSG num2str(i)];
  pong = char_strings.CharPingPong(ping);
  if (!strcmp(ping, pong))
    error("Test PingPong 1 failed");
  endif
endfor

for i = 0:count-1
  ping = [OTHERLAND_MSG num2str(i)];
  pong = char_strings.CharArrayPingPong(ping);
  if (!strcmp(ping, pong))
    error("Test PingPong 2 failed");
  endif
endfor

# CharArrayDimsPingPong takes a fixed char[16] buffer, so the string must fit in 16 bytes
for i = 0:count-1
  ping = ["PingPong" num2str(i)];
  pong = char_strings.CharArrayDimsPingPong(ping);
  if (!strcmp(ping, pong))
    error("Test PingPong 3 failed");
  endif
endfor

# variables
for i = 0:count-1
  expected = [OTHERLAND_MSG num2str(i)];
  char_strings.cvar.global_char = expected;
  if (!strcmp(char_strings.cvar.global_char, expected))
    error("Test variables 1 failed");
  endif
endfor

# global_char_array1 is char[] with no dimension => read-only in Octave (VARIN typemap
# undefined, see %warnfilter in char_strings.i). It retains its initial value.
for i = 0:count-1
  if (!strcmp(char_strings.cvar.global_char_array1, CPLUSPLUS_MSG))
    error("Test variables 2 failed");
  endif
endfor

for i = 0:count-1
  expected = [OTHERLAND_MSG num2str(i)];
  char_strings.cvar.global_char_array2 = expected;
  if (!strcmp(char_strings.cvar.global_char_array2, expected))
    error("Test variables 3 failed");
  endif
endfor

for i = 0:count-1
  if (!strcmp(char_strings.cvar.global_const_char, CPLUSPLUS_MSG))
    error("Test variables 4 failed");
  endif
endfor

for i = 0:count-1
  if (!strcmp(char_strings.cvar.global_const_char_array1, CPLUSPLUS_MSG))
    error("Test variables 5 failed");
  endif
endfor

for i = 0:count-1
  if (!strcmp(char_strings.cvar.global_const_char_array2, CPLUSPLUS_MSG))
    error("Test variables 6 failed");
  endif
endfor

# char *& tests
for i = 0:count-1
  if (!strcmp(char_strings.GetCharPointerRef(), CPLUSPLUS_MSG))
    error("Test char pointer ref get failed");
  endif
endfor

for i = 0:count-1
  if (!char_strings.SetCharPointerRef([OTHERLAND_MSG num2str(i)], i))
    error("Test char pointer ref set failed");
  endif
endfor

for i = 0:count-1
  if (!strcmp(char_strings.GetConstCharPointerRef(), CPLUSPLUS_MSG))
    error("Test const char pointer ref get failed");
  endif
endfor

for i = 0:count-1
  if (!char_strings.SetConstCharPointerRef([OTHERLAND_MSG num2str(i)], i))
    error("Test const char pointer ref set failed");
  endif
endfor
