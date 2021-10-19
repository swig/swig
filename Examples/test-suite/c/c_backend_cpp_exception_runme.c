#include <assert.h>

#define SWIG_DEFINE_WRAPPER_ALIASES
#include "c_backend_cpp_exception/c_backend_cpp_exception_wrap.h"

int main()
{
	assert(checkVal == 0);
	throwSomeKnownException();
	assert(checkVal == 1);
	throwSomeUnknownException();
	assert(checkVal == 2);

	return 0;
}