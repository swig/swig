/* -------------------------------------------------------------------------
 * cuda.i
 *
 * CUDA Fortran/C interoperability.
 * ------------------------------------------------------------------------- */

#ifdef SWIG_FORTRAN_OPENACC
#error "Can't use both CUDA *and* OpenACC compatibility layers."
#endif
#define SWIG_FORTRAN_CUDA

%{
#include <cuda_runtime.h>
%}

%include <forarray.swg>

// Load CUDA types
%fragment("f_use_cudafor", "fmodule") %{ use cudafor %}

// Add array wrapper to Fortran types when used
%fragment("SwigDevArrayWrapper_f", "fparams", noblock=1,
          fragment="f_use_openacc") {
 type, bind(C) :: SwigDevArrayWrapper
  type(C_DEVPTR), public :: data = C_NULL_DEVPTR
  integer(C_SIZE_T), public :: size = 0
 end type
}

%define FORT_DEVICEPTR_TYPEMAP(VTYPE, CPPTYPE...)

  // C wrapper type: pointer to array wrapper
  %typemap(ctype, noblock=1, out="SwigArrayWrapper",
         null="SwigArrayWrapper_uninitialized()",
         fragment="SwigArrayWrapper_uninitialized") CPPTYPE {
    SwigArrayWrapper*
  }
  %typemap(imtype, fragment="SwigDevArrayWrapper_f") CPPTYPE
    "type(SwigDevArrayWrapper)"

  // Fortran pointer has
  %typemap(ftype, noblock=1) CPPTYPE {
    $typemap(imtype, VTYPE), device, dimension(:), intent(inout)
  }

  %typemap(fin, noblock=1, fragment="f_use_cudafor") CPPTYPE {
    $1%data = acc_deviceptr($input)
    $1%size = size($input)
  }

%enddef
