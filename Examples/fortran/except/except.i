/* File : except.i */
%module except

/* Rename the error variables */
#define SWIG_FORTRAN_ERROR_INT ierr_test
#define SWIG_FORTRAN_ERROR_STR get_serr_test

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
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
