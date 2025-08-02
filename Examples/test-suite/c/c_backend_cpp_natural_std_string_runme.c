#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "c_backend_cpp_natural_std_string/c_backend_cpp_natural_std_string_wrap.h"

int main()
{
	char buf[] = "World, ";
	char *myComposedString = c_backend_cpp_natural_std_string_myStringAppend(buf, "Hello!");

	assert(myComposedString);
	assert(strcmp(myComposedString, "World, Hello!") == 0);

	free(myComposedString);

	return 0;
}
