%module javascript_unicode

%newobject copy_string;

%inline %{
#include <string.h>
const char* copy_string(const char* str) {
	return strdup(str);
}
%}
