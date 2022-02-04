/* File : downstream.i */
%module downstream

/* Since the exception handling code is linked externally (defined in the
 * 'except' module), we must redefine the error names being used and %include
 * this special exception handling declaration. */
#define SWIG_FORTRAN_ERROR_INT ierr_test
#define SWIG_FORTRAN_ERROR_STR get_serr_test
%include "extern_exception.i"

%import "example.i"

%inline %{
void throw_error()
{
    throw std::logic_error("Threw an error for you");
}
%}



