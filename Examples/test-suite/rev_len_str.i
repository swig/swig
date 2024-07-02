/*
A test case for reverse length string typemap
*/

%module rev_len_str

%apply (size_t LENGTH, const char *STRING) { (size_t len, const char *str, ) }

%inline %{
struct Test {
  size_t strlen(size_t len, const char *str) {
    return len;
  }
};
%}

// Remove string handling typemaps and treat as pointer
%typemap(freearg) SWIGTYPE * ""
%apply SWIGTYPE * { char * }
