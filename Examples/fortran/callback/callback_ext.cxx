#ifndef SWIGEXPORT
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(STATIC_LINKED)
#     define SWIGEXPORT
#   else
#     define SWIGEXPORT __declspec(dllexport)
#   endif
# else
#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#     define SWIGEXPORT __attribute__ ((visibility("default")))
#   else
#     define SWIGEXPORT
#   endif
# endif
#endif

#define SWIGINTERN static
#define SWIGEXTERN extern

#include <stdlib.h>
#include <string.h>
#include <string>
#include <iostream>

#include "callback.h"

struct SwigArrayWrapper {
    void* data;
    size_t size;
};

typedef SwigArrayWrapper (*swigc_fp_transform)(SwigArrayWrapper *farg1);

extern "C" {
swigc_fp_transform swigc_fortran_cb = NULL;
}

std::string director_cb_impl(const std::string& str) {
  /* convert str -> array wrapper */
  SwigArrayWrapper arg1;
  SwigArrayWrapper fresult;
  arg1.data = (str.empty() ? NULL : const_cast<char*>(str.c_str()));
  arg1.size = str.size();

  /* pass through C fortran interface */
  fresult = swigc_fortran_cb(&arg1);

  /* convert result back to string */
  char* result = static_cast<char*>(fresult.data);
  return std::string(result, result  + fresult.size);
}

extern "C" {

// director_cb: callback function that can be referenced by fortran
SWIGEXPORT SWIGEXTERN std::string (*const swigc_director_cb)(std::string const &) = (std::string (*)(std::string const &s))(director_cb_impl);

SwigArrayWrapper crap(SwigArrayWrapper *farg1)
{
  return *farg1;
}

void printcrap() {
  using namespace std;
  swigc_fortran_cb = &crap;
  std::string temp("this is a string yo");
  cout << "Calling director cb: " << swigc_director_cb(temp) << endl;
}

}
