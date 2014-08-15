% test function for preproc_constants
function test_global()
global CONST_INT1
global CONST_DOUBLE3
global CONST_BOOL1
global CONST_CHAR
global CONST_STRING1

assert(CONST_INT1,      10)
assert(CONST_DOUBLE3,   12.3)
assert(CONST_BOOL1,     true)
assert(CONST_CHAR,      'x')
assert(CONST_STRING1,   'const string')

