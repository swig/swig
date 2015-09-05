import preproc_constants.*

assert(isequal(CONST_INT1,      10), 'CONST_INT1 is %d but should be 10', CONST_INT1)
assert(isequal(CONST_DOUBLE3,   12.3), 'CONST_DOUBLE3 is %g but should be 12.3', CONST_DOUBLE3)
assert(isequal(CONST_BOOL1,     true), 'CONST_BOOL1 should be true', CONST_BOOL1)
assert(isequal(CONST_CHAR,      'x'), 'CONST_CHAR is %s but should be 10', CONST_CHAR)
assert(isequal(CONST_STRING1,   'const string'), 'CONST_STRING1 is "%s" but should be "const string"', CONST_STRING1)

% Test global constants can be seen within functions

preproc_constants_test_global
