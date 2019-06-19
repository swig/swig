/* -------------------------------------------------------------------------
 * forarray.swg
 * ------------------------------------------------------------------------- */
%include <typemaps/fragments.swg>

/* -------------------------------------------------------------------------
 * FRAGMENTS
 * ------------------------------------------------------------------------- */

#ifdef __cplusplus
%fragment("SwigArrayWrapper", "header", fragment="<stdlib.h>") %{
struct SwigArrayWrapper {
    void* data;
    size_t size;
};
%}
#else
%fragment("SwigArrayWrapper", "header", fragment="<stdlib.h>") %{
typedef struct {
    void* data;
    size_t size;
} SwigArrayWrapper;
%}
#endif

%fragment("SwigArrayWrapper_uninitialized", "header", fragment="SwigArrayWrapper") %{
SWIGINTERN SwigArrayWrapper SwigArrayWrapper_uninitialized() {
  SwigArrayWrapper result;
  result.data = NULL;
  result.size = 0;
  return result;
}
%}

// Add array wrapper to Fortran types when used
%fragment("SwigArrayWrapper_f", "fdecl", noblock=1)
{ type, bind(C) :: SwigArrayWrapper
  type(C_PTR), public :: data = C_NULL_PTR
  integer(C_SIZE_T), public :: size = 0
 end type}

// Generate a wrapper function for cstdlib's 'free' memory function
%fragment("SWIG_free_f", "finterfaces", noblock=1)
{ subroutine SWIG_free(cptr) &
  bind(C, name="free")
 use, intrinsic :: ISO_C_BINDING
 type(C_PTR), value :: cptr
end subroutine}

/* -------------------------------------------------------------------------
 * MACROS
 * ------------------------------------------------------------------------- */
/*!
 * \def %fortran_array
 *
 * Use the \c SwigArrayWrapper for the ISO C binding layer.
 *
 * This only defines ctype and imtype; it does not define conversion routines.
 * We use a macro rather than applying or copying a typedef because this is used 
 * in both single- and multi-argument typemap matches.
 */
%define %fortran_array(CPPTYPE...)
  // C wrapper type: pointer to templated array wrapper
  %typemap(ctype, in="SwigArrayWrapper*",
         null="SwigArrayWrapper_uninitialized()",
         fragment="SwigArrayWrapper_uninitialized", noblock=1) CPPTYPE
    "SwigArrayWrapper"
  
  // Interface type: fortran equivalent of "ctype"
  // Since the type is declared in the module, it's necessary to use the
  // fortran "import" statement to bring it into scope.
  %typemap(imtype, fragment="SwigArrayWrapper_f", noblock=1) CPPTYPE
    "type(SwigArrayWrapper)"
%enddef

/* ------------------------------------------------------------------------- */
/*!
 * \def %fortran_array_pointer
 *
 * Wrap intermediate data values as array pointers.
 *
 * This defines:
 * - C type interface
 * - IM type interface
 * - FIN/FOUT
 * - FTYPE array pointer
 */
%define %fortran_array_pointer(VTYPE, CPPTYPE...)
  %fortran_array(CPPTYPE)

  // Fortran proxy code: input is target 1D array
  %typemap(ftype, in={$typemap(imtype, VTYPE), dimension(:), target}, noblock=1) CPPTYPE {
    $typemap(imtype, VTYPE), dimension(:), pointer
  }
  
  // Fortran proxy translation code: convert from ftype $input to imtype $1
  // Note that we take the address of the first element instead of the array,
  // because nonallocatable deferred-size arrays *cannot* be referenced in
  // standard F2003. This is because they might be slices of other arrays
  // (noncontiguous). It is the caller's responsibility to ensure only
  // contiguous arrays are passed. Conceivably we could improve this to use
  // strided access by also passing c_loc($input(2)) and doing pointer
  // arithmetic.
  // TODO: use the "CONTIGUOUS" attribute if f2008 is being used to guarantee
  // that we can get the C location of the input array directly.
  %typemap(fin, temp={$typemap(imtype, VTYPE), pointer}, noblock=1) CPPTYPE {
    if (size($input) > 0) then
      $1_temp => $input(1)
      $1%data = c_loc($1_temp)
      $1%size = size($input)
    else
      $1%data = c_null_ptr
      $1%size = 0
    end if
  }
  
  // Fortran proxy translation code: convert from imtype 1 to ftype $result
  %typemap(fout, noblock=1) CPPTYPE {
    if ($1%size > 0) then
      call c_f_pointer($1%data, $result, [$1%size])
    else
      $result => NULL()
    endif
  }
%enddef

/* ------------------------------------------------------------------------- */
/*!
 * \def %fortran_array_pointer_and_ref
 *
 * Convert a C++ input argument to an array pointer.
 *
 * For example, the function
 * \code
   void f(double** data, size_t* size);
   \endcode
 * would take a Fortran array pointer as an (INOUT) argument.
 *
 * This defines:
 * - C type interface
 * - IM type interface
 * - FIN
 * - FTYPE array pointer
 *
 * which means you still must define the C++ <--> C conversions elsewhere.
 * Make sure to add the `match="in"` keyword to the `argout` typemap.
 */
%define %fortran_array_handle(VTYPE, CPPTYPE...)

  // Input arguments for pointer-by-ref are the same
  %typemap(ftype, in={$typemap(imtype, VTYPE), dimension(:), pointer, intent(inout)}, noblock=1) CPPTYPE& {
    $typemap(imtype, VTYPE), dimension(:), pointer
  }
  %typemap(fin, match="ftype", noblock=1) CPPTYPE& {
    if (associated($input) .and. size($input) > 0) then
      $1%data = c_loc($input)
      $1%size = size($input)
    else
      $1%data = c_null_ptr
      $1%size = 0
    end if
  }
  %typemap(imtype) CPPTYPE& = CPPTYPE;
  %typemap(ctype) CPPTYPE& = CPPTYPE;

  // Update the resulting Fortran pointer.
  %typemap(fargout, match="argout", noblock=1) CPPTYPE& {
    if ($1%size > 0) then
      call c_f_pointer($1%data, $input, [$1%size])
    else
      $input => NULL()
    endif
  }
%enddef

