%module string_simple

%newobject copy_str;

%inline %{
#include <stdlib.h>
#include <string.h>
const char* copy_str(const char* str) {
  size_t len = strlen(str);
  char* newstring = (char*) malloc(len + 1);
  strcpy(newstring, str);
  return newstring;
}
%}
