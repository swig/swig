%module string_simple

%newobject copy_str;

#ifdef __cplusplus
%inline %{
#include <stdlib.h>
#include <string.h>
const char* copy_str(const char* str) {
  size_t len = strlen(str);
  char* newstring = new char[len + 1];
  strcpy(newstring, str);
  return newstring;
}
%}
#else
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
#endif
