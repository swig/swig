/* -------------------------------------------------------------------------
 * openacc.i
 *
 * OpenACC Fortran/C interoperability. Assumes a typedef "HAVE_ACC" is
 * defined in the target code -- add

     %insert("runtime") %{
     #include "myconfig.h"
     %}

 * in your code to guarantee that HAVE_ACC is set correctly.
 *
 * ------------------------------------------------------------------------- */
#ifdef SWIG_FORTRAN_CUDA
#error "Can't use both CUDA *and* OpenACC compatibility layers."
#endif
#define SWIG_FORTRAN_OPENACC

%include <forarray.swg>

// Load openacc types
%fragment("f_use_openacc", "fmodule") %{ use openacc %}

// Add array wrapper to Fortran types when used
%fragment("SwigDevArrayWrapper_f", "fpublic", noblock=1,
          fragment="f_use_openacc") {
type, bind(C) :: SwigDevArrayWrapper
  type(C_DEVPTR), public :: data = C_NULL_DEVPTR
  integer(C_SIZE_T), public :: size = 0
end type
}

%define FORT_DEVICEPTR_TYPEMAP(VTYPE, CPPTYPE...)

  // Use array type for C interface
  FORT_ARRAYWRAP_TYPEMAP(CPPTYPE)

  // Override Fortran 'imtype': we want device pointer
  %typemap(imtype, import="SwigDevArrayWrapper", fragment="SwigDevArrayWrapper_f") CPPTYPE
    "type(SwigDevArrayWrapper)"

  %typemap(fin, noblock=1, fragment="f_use_openacc") CPPTYPE {
    $1%data = acc_deviceptr($input)
    $1%size = size($input)
  }

  %typemap(ftype, noblock=1) CPPTYPE {
    $typemap(imtype, VTYPE), dimension(:)
  }

  // acc_deviceptr returns null if the device data isn't present
  %typemap(check, noblock=1) CPPTYPE {
    if ($2 && !thrust::raw_pointer_cast($1)) {
      SWIG_exception_impl("$decl", SWIG_TypeError, \
                          "Array is not present on device", return $null); \
    }
  }

%enddef


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
