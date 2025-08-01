/*
 * A test case for reverse length string typemap
 */

%module char_binary_rev_len


#if !defined(SWIGC)
/* There is no concept of a higher level binary string in C */
%apply (size_t LENGTH, const char *STRING) { (size_t len, const char *str, ) }
%apply (size_t LENGTH, const char *STRING) { (size_t leng, const char *stri, ) }
#endif

%inline %{
struct Test {
  size_t isize;
  size_t strlen(size_t len, const char *str) {
    return len;
  }
  Test() { isize = 0; }
  Test(size_t leng, const char *stri) { isize = leng; }
  size_t getisize() { return  isize; }
};
%}
