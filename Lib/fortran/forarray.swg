/* -------------------------------------------------------------------------
 * forarray.swg
 * ------------------------------------------------------------------------- */
%include <typemaps/fragments.swg>

/* -------------------------------------------------------------------------
 * FRAGMENTS
 * ------------------------------------------------------------------------- */

%fragment("SwigArrayWrapper", "header") %{
struct SwigArrayWrapper {
    void* data;
    std::size_t size;
};

SWIGINTERN SwigArrayWrapper SwigArrayWrapper_uninitialized() {
  SwigArrayWrapper result;
  result.data = NULL;
  result.size = 0;
  return result;
}
%}

// Add array wrapper to Fortran types when used
%fragment("SwigArrayWrapper_f", "fpublic", noblock="1") %{
type, bind(C) :: SwigArrayWrapper
  type(C_PTR), public :: data = C_NULL_PTR
  integer(C_SIZE_T), public :: size = 0
end type
%}

// Generate a wrapper function for cstdlib's 'free' memory function
%fragment("SWIG_free_f", "finterfaces", fragment="<stdlib.h>") %{
subroutine SWIG_free(ptr) &
  bind(C, name="free")
 use, intrinsic :: ISO_C_BINDING
 type(C_PTR), value :: ptr
end subroutine
%}

/* -------------------------------------------------------------------------
 * MACROS
 * ------------------------------------------------------------------------- */
/*!
 * \def FORT_ARRAYPTR_TYPEMAP
 *
 * Wrap intermediate data values as array pointers.
 *
 * This defines:
 * - C type interface
 * - IM type interface
 * - Fortran in/out
 */
%define FORT_ARRAYPTR_TYPEMAP(VTYPE, CPPTYPE...)
  // C wrapper type: pointer to templated array wrapper
  %typemap(ctype, noblock=1, out="SwigArrayWrapper",
         null="SwigArrayWrapper_uninitialized()",
         fragment="SwigArrayWrapper") CPPTYPE {
    SwigArrayWrapper*
  }
  
  // Interface type: fortran equivalent of "ctype"
  // Since the type is declared in the module, it's necessary to use the
  // fortran "import" statement to bring it into scope.
  %typemap(imtype, import="SwigArrayWrapper", fragment="SwigArrayWrapper_f") CPPTYPE
    "type(SwigArrayWrapper)"
  
  // Fortran proxy code: input is target 1D array
  %typemap(ftype, out={$typemap(imtype, VTYPE), dimension(:), pointer}, noblock=1) CPPTYPE {
    $typemap(imtype, VTYPE), dimension(:), target
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
  %typemap(findecl, noblock=1) CPPTYPE {
    $typemap(imtype, VTYPE), pointer :: $1_view
  }
  
  %typemap(fin) CPPTYPE %{
    $1_view => $input(1)
    $1%data = c_loc($1_view)
    $1%size = size($input)
  %}
  
  // Fortran proxy translation code: convert from imtype 1 to ftype $result
  %typemap(fout) CPPTYPE %{
    call c_f_pointer($1%data, $result, [$1%size])
  %}
%enddef
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
