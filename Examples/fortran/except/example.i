/* File : example.i */
%module example

/* Rename the error variables' internal C symbols */
#define SWIG_FORTRAN_ERROR_INT ierr_test
#define SWIG_FORTRAN_ERROR_STR get_serr_test

/* Restore names in the wrapper code */
%rename(ierr) ierr_test;
%rename(get_serr) get_serr_test;
%include <std_except.i>

%exception {
  SWIG_check_unhandled_exception();
  try {
    $action
  }
  catch (const std::exception& e) {
    SWIG_exception(SWIG_RuntimeError, e.what());
  }
}

%{
#include <stdexcept>
#include <iostream>
%}
%inline {
void do_it(int i) {
  if (i < 0)
    throw std::logic_error("NOOOOO");
  std::cout << "Yes! I got " << i
    << std::endl;
}
void do_it_again(int i) { do_it(i); }
}

%{
/* Stand-in for an externally declared error code. Since we renamed the SWIG one
 * using SWIG_FORTRAN_ERROR_INT, we should be good. */
SWIGEXPORT int ierr = 0;
%}
