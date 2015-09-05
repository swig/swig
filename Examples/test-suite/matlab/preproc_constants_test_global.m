% test function for preproc_constants
function test_global()
global CONST_INT1
global CONST_DOUBLE3
global CONST_BOOL1
global CONST_CHAR
global CONST_STRING1

assert(isequal(CONST_INT1,      10), 'in function: CONST_INT1 is %d but should be 10', CONST_INT1)
assert(isequal(CONST_DOUBLE3,   12.3), 'in function: CONST_DOUBLE3 is %g but should be 12.3', CONST_DOUBLE3)
assert(isequal(CONST_BOOL1,     true), 'in function: CONST_BOOL1 should be true', CONST_BOOL1)
assert(isequal(CONST_CHAR,      'x'), 'in function: CONST_CHAR is %s but should be 10', CONST_CHAR)
assert(isequal(CONST_STRING1,   'const string'), 'in function: CONST_STRING1 is "%s" but should be "const string"', CONST_STRING1)

keyboard
