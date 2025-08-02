#include <assert.h>

#include "c_backend_cpp_exception/c_backend_cpp_exception_wrap.h"

int main()
{
	assert(c_backend_cpp_exception_checkVal_get() == 0);
	c_backend_cpp_exception_throwSomeKnownException();
	assert(c_backend_cpp_exception_checkVal_get() == 1);
	c_backend_cpp_exception_throwSomeUnknownException();
	assert(c_backend_cpp_exception_checkVal_get() == 2);

	return 0;
}
