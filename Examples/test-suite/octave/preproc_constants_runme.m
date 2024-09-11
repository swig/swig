preproc_constants

assert(CONST_INT1,      10)
assert(CONST_DOUBLE3,   12.3)
assert(CONST_BOOL1,     true)
assert(CONST_CHAR,      'x')
assert(CONST_STRING1,   "const string")

# Test global constants can be seen within functions
function test_global()
global CONST_INT1
global CONST_DOUBLE3
global CONST_BOOL1
global CONST_CHAR
global CONST_STRING1
global CONST_STRING4

assert(CONST_INT1,      10)
assert(CONST_DOUBLE3,   12.3)
assert(CONST_BOOL1,     true)
assert(CONST_CHAR,      'x')
assert(CONST_STRING1,   "const string")
if (false)
  # Currently SWIG/Octave truncates at a zero byte in a string constant.
  # strings support embedded zero bytes so this ought to work, but is an
  # uncommon case.
  assert(CONST_STRING4, "zer\0zer\0")
else
  # Test the current behaviour for now to ensure this testcase gets updated
  # when this gets fixed, and also to check we don't mangle the value in some
  # other way.
  assert(CONST_STRING4, "zer")
endif
endfunction

test_global
