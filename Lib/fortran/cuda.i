/* -------------------------------------------------------------------------
 * cuda.i
 *
 * CUDA Fortran/C interoperability. Assumes a typedef "HAVE_CUDA" is
 * defined in the target code -- add

     %insert("runtime") %{
     #include "myconfig.h"
     %}

 * in your code to guarantee that HAVE_CUDA is set correctly.
 *
 * ------------------------------------------------------------------------- */

#ifdef SWIG_FORTRAN_OPENACC
#error "Can't use both CUDA *and* OpenACC compatibility layers."
#endif
#define SWIG_FORTRAN_CUDA

%{
#ifdef HAVE_CUDA
#include <cuda_runtime.h>
#endif
%}

#define __host__

// Load CUDA extensions?
%fragment("f_use_cudafor", "fmodule") %{ use cudafor %}

%define FORT_DEVICEPTR_TYPEMAP(VTYPE, CPPTYPE...)

  // C wrapper type: pointer to array wrapper
  %typemap(ctype, noblock=1, out="SwigArrayWrapper",
         null="SwigArrayWrapper_uninitialized()",
         fragment="SwigArrayWrapper_uninitialized") CPPTYPE {
    SwigArrayWrapper*
  }
  //
  %typemap(imtype, import="SwigDevArrayWrapper", fragment="SwigDevArrayWrapper_f") CPPTYPE
    "type(SwigDevArrayWrapper)"

  %typemap(ftype, noblock=1) CPPTYPE {
    $typemap(imtype, VTYPE), device, dimension(:), intent(inout)
  }

%enddef


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
