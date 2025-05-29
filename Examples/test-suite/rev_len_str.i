/*
 * A test case for reverse length string typemap
 */

%module rev_len_str

#if !defined(SWIGC) && !defined(SWIGOCAML) && !defined(SWIGGUILE)
%apply (size_t LENGTH, const char *STRING) { (size_t len, const char *str, ) }
#endif

%inline %{
struct Test {
  size_t strlen(size_t len, const char *str) {
    return len;
  }
};
%}
