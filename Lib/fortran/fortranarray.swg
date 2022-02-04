/* -------------------------------------------------------------------------
 * forarray.swg
 * ------------------------------------------------------------------------- */
%include <typemaps/fragments.swg>

/* -------------------------------------------------------------------------
 * FRAGMENTS
 * ------------------------------------------------------------------------- */

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
  %typemap(ftype, in="$typemap(imtype, " #VTYPE "), dimension(:), target", noblock=1) CPPTYPE {
    $typemap(imtype, VTYPE), dimension(:), pointer
  }
  
  // Look up typemaps defined by %fortran_intrinsic
  %typemap(fin, noblock=1) CPPTYPE {$typemap(fin, VTYPE ARRAY[])}
  %typemap(fout, noblock=1) CPPTYPE {$typemap(fout, VTYPE ARRAY[])}
%enddef

/* ------------------------------------------------------------------------- */
/*!
 * \def %fortran_array_handle
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
  %typemap(ftype, in="$typemap(imtype, " #VTYPE "), dimension(:), pointer, intent(inout)", noblock=1) CPPTYPE& {
    $typemap(imtype, VTYPE), dimension(:), pointer
  }
  %typemap(fin, match="ftype", noblock=1) CPPTYPE& {$typemap(fin, VTYPE ARRAY[])}
  %typemap(imtype) CPPTYPE& = CPPTYPE;
  %typemap(ctype) CPPTYPE& = CPPTYPE;

  // Update the resulting Fortran pointer, but only by reference (not const ref)
  %typemap(fargout, match="fin", noblock=1) CPPTYPE& = VTYPE ARRAY[];
  %typemap(fargout, noblock=1) const CPPTYPE& {};
%enddef

