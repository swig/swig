/* -------------------------------------------------------------------------
 * openacc.i
 * ------------------------------------------------------------------------- */
#ifdef SWIG_FORTRAN_CUDA
#error "Can't use both CUDA *and* OpenACC compatibility layers."
#endif
#define SWIG_FORTRAN_OPENACC

%include <fortranarray.swg>

// Load openacc types
%fragment("f_use_openacc", "fuse") %{ use openacc
%}

// Add array wrapper to Fortran types when used
%fragment("SwigDevArrayWrapper_f", "fdecl", noblock=1,
          fragment="f_use_openacc") {
 type, bind(C) :: SwigDevArrayWrapper
  type(C_DEVPTR), public :: data = C_NULL_DEVPTR
  integer(C_SIZE_T), public :: size = 0
 end type
}

%define %fortran_deviceptr(VTYPE, CPPTYPE...)

  // Use array type for C interface
  %fortran_array(CPPTYPE)

  // Override Fortran 'imtype': we want device pointer
  %typemap(imtype, fragment="SwigDevArrayWrapper_f") CPPTYPE
    "type(SwigDevArrayWrapper)"

  %typemap(fin, noblock=1, fragment="f_use_openacc") CPPTYPE {
    $1%data = acc_deviceptr($input)
    $1%size = size($input, kind=c_int)
  }

  %typemap(ftype, noblock=1) CPPTYPE {
    $typemap(imtype, VTYPE), dimension(:)
  }

%enddef
