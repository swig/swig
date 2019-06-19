/* -------------------------------------------------------------------------
 * fundamental.swg
 *
 * Define fundamental/primitive/built-in types that override the SWIGTYPE
 * class definitions. Since most of the scalar types and their derivatives are
 * treated identically, we define typemaps for a fake type "FORTRAN_INTRINSIC_TYPE" and
 * %apply them where needed. This also makes debugging typemaps with
 * -debug-tmsearch easier.
 * ------------------------------------------------------------------------- */

%include <typemaps/swigmacros.swg>

#ifdef __cplusplus
namespace std
{
#endif
typedef unsigned long size_t;
typedef long ptrdiff_t;
#ifdef __cplusplus
}
using std::size_t;
using std::ptrdiff_t;
#endif

/* -------------------------------------------------------------------------
 * FRAGMENTS
 * ------------------------------------------------------------------------- */
/* Convert Fortran logical values to and from C-bound integers */
%fragment("SWIG_fin"{bool}, "fsubprograms", noblock=1) {
subroutine %fortrantm(fin, bool)(finp, iminp)
  use, intrinsic :: ISO_C_BINDING
  logical, intent(IN) :: finp
  integer(kind=C_INT), intent(OUT) :: iminp
  if (finp .eqv. .true.) then
    iminp = 1
  else
    iminp = 0
  end if
end subroutine
}

%fragment("SWIG_fout"{bool}, "fsubprograms", noblock=1) {
subroutine %fortrantm(fout, bool)(imout, fout)
  use, intrinsic :: ISO_C_BINDING
  integer(kind=C_INT), intent(IN) :: imout
  logical, intent(OUT) :: fout
  ! TODO: fout = (imout /= 0) ???
  if (imout /= 0) then
    fout = .true.
  else
    fout = .false.
  end if
end subroutine
}

/* -------------------------------------------------------------------------
 * MACROS
 * ------------------------------------------------------------------------- */
/*!
 * \def %fortran_typemap_finout
 */
%define %fortran_typemap_finout(CPPTYPE)
  // Typemap for converting to array wrapper
  %typemap(fin, fragment="SWIG_fin"{CPPTYPE}, noblock=1) CPPTYPE {
  call %fortrantm(fin, CPPTYPE)($input, $1)
  }
  %typemap(fout, fragment="SWIG_fout"{CPPTYPE}, noblock=1) CPPTYPE {
  call %fortrantm(fout, CPPTYPE)($1, $result)
  }
%enddef

/*!
 * \def %fortran_apply_typemaps
 * \brief Copy *fundamental* typemaps to the given type.
 *
 * These should be exactly the typemaps declared as FORTRAN_INTRINSIC_TYPE. 
 */
%define %fortran_apply_typemaps(SRCTYPE, DSTTYPE)
  // Copy all relevant typemaps
  %apply SRCTYPE&       { DSTTYPE& };
  %apply SRCTYPE&&      { DSTTYPE&& };
  %apply const SRCTYPE& { const DSTTYPE& };

  // Special bind-c types
  %typemap(bindc) DSTTYPE[ANY] = SRCTYPE[ANY];
  %typemap(bindc) DSTTYPE[ANY][ANY] = SRCTYPE[ANY][ANY];
  %typemap(bindc) DSTTYPE[ANY][ANY][ANY] = SRCTYPE[ANY][ANY][ANY];
%enddef

/*!
 * \def %fortran_intrinsic
 * \brief Add typemaps for fundamental ISO-C compatible types.
 */
%define %fortran_intrinsic(CTYPE, FTYPE)
  %fortran_apply_typemaps(FORTRAN_INTRINSIC_TYPE, CTYPE)
  
  // Regular values are passed as pointers and returned by value
  %typemap(ctype, in={const CTYPE*}) CTYPE
   %{CTYPE%}
  %typemap(imtype, in={FTYPE, intent(in)}) CTYPE
   %{FTYPE%}
  %typemap(ftype, in={FTYPE, intent(in)}) CTYPE
   %{FTYPE%}
  %typemap(bindc, in={FTYPE, value}) CTYPE
   %{FTYPE%}
  %typemap(in) CTYPE = FORTRAN_INTRINSIC_TYPE;
  %typemap(out) CTYPE = FORTRAN_INTRINSIC_TYPE;
  %typemap(fin) CTYPE = FORTRAN_INTRINSIC_TYPE;
  %typemap(fout) CTYPE = FORTRAN_INTRINSIC_TYPE;

  %typemap(fin) CTYPE = FORTRAN_INTRINSIC_TYPE;
  %typemap(fout) CTYPE = FORTRAN_INTRINSIC_TYPE;
%enddef

/*!
 * \def %fortran_unsigned
 * \brief Apply typemaps for treating signed/unsigned variables
 */
%define %fortran_unsigned(SRCTYPE, DSTTYPE)
  %apply SRCTYPE { DSTTYPE };
  %fortran_apply_typemaps(FORTRAN_UNSIGNED_TYPE, DSTTYPE)

  %typemap(out, noblock=1) DSTTYPE& {
     $result = (SRCTYPE*)($1);
  }
%enddef

/* -------------------------------------------------------------------------
 * GENERIC FUNDAMENTAL TYPE
 * ------------------------------------------------------------------------- */
/*
 * The most important thing for the fundamental types is keeping their 'imtype'
 * and 'ctype' consistent, and ensuring that those types are ISO C
 * interoperable. All primitive types are interoperable, but some (such as
 * unsigned types) are implicitly converted to signed types, and one (the
 * boolean/logical type) has a different fundamental representation even though
 * both C_BOOL and bool have the same size. Some structs of primitive types
 * (see the %fortran_struct feature) can also be made interoperable.
 *
 * - Arguments in Fortran are passed by pointer reference, and return
 * types are passed by value.
 * - Returning by const reference is automatically turned into return-by-value
 * - Mutable references that are arguments get the 'inout' qualifier in Fortran,
 *   whereas values and const references are simply 'in'.
 * - Mutable references that are *return* values are passed as pointers, and on
 *   the Fortan side these become 'pointer' types.
 * - Fixed-size arrays are passed as known-size array pointers, but otherwise
 *   they are treated as pointers to scalar data.
 *
 * Note that $1_ltype is the same for FORTRAN_INTRINSIC_TYPE*, FORTRAN_INTRINSIC_TYPE&,
 * FORTRAN_INTRINSIC_TYPE[], and FORTRAN_INTRINSIC_TYPE[ANY], and the const
 * versions of those.
 */

// Fundamental types
%typemap(in, noblock=1) FORTRAN_INTRINSIC_TYPE {
  $1 = ($1_ltype)(*$input);
}
%typemap(out, noblock=1) FORTRAN_INTRINSIC_TYPE {
  $result = ($1_ltype)($1);
}
%typemap(fin) FORTRAN_INTRINSIC_TYPE
  "$1 = $input"
%typemap(fout) FORTRAN_INTRINSIC_TYPE
  "$result = $1"

// Mutable references are passed by pointers as arguments, but they're
// *returned* as actual pointers (becoming Fortran pointers).
%typemap(ctype) FORTRAN_INTRINSIC_TYPE&
  "$typemap(ctype, $*1_ltype)*"
%typemap(imtype, in="type(C_PTR), value") FORTRAN_INTRINSIC_TYPE&
  "type(C_PTR)"
%typemap(ftype, in="$typemap(ftype, $*1_ltype), target, intent(inout)") FORTRAN_INTRINSIC_TYPE&
  "$typemap(ftype, $*1_ltype), pointer"
%typemap(bindc, in="$typemap(imtype, $*1_ltype)") FORTRAN_INTRINSIC_TYPE&
  "type(C_PTR)"
%typemap(in, noblock=1) FORTRAN_INTRINSIC_TYPE& {
   $1 = ($1_ltype)($input);
}
%typemap(out) FORTRAN_INTRINSIC_TYPE&
  "$result = $1;"
%typemap(fin) FORTRAN_INTRINSIC_TYPE&
  "$1 = c_loc($input)"
%typemap(fout) FORTRAN_INTRINSIC_TYPE&
  "call c_f_pointer($1, $result)"

// We treat const references as values for fundamental types
// Since ctype/imtype/ftype aren't defined for 'FORTRAN_INTRINSIC_TYPE' (just for each fundamental type), use $typemap to retrieve the corresponding values.
%apply FORTRAN_INTRINSIC_TYPE { const FORTRAN_INTRINSIC_TYPE& };
%typemap(ctype, in="const $typemap(ctype, $*1_ltype)*") const FORTRAN_INTRINSIC_TYPE&
  "$typemap(ctype, $*1_ltype)"
%typemap(imtype, in="$typemap(imtype, $*1_ltype), intent(in)") const FORTRAN_INTRINSIC_TYPE&
  "$typemap(imtype, $*1_ltype)"
%typemap(ftype, in="$typemap(ftype, $*1_ltype), intent(in)" ) const FORTRAN_INTRINSIC_TYPE&
  "$typemap(ftype, $*1_ltype)"
%typemap(in, noblock=1) const FORTRAN_INTRINSIC_TYPE& ($*1_ltype temp) {
  temp = ($*1_ltype)(*$input);
  $1 = &temp;
}
%typemap(out) const FORTRAN_INTRINSIC_TYPE& 
  "$result = *$1;"

// Treat rvalue references as const refrerences
%apply const FORTRAN_INTRINSIC_TYPE& { FORTRAN_INTRINSIC_TYPE&& };

/* -------------------------------------------------------------------------
 * ARRAY TYPES
 * ------------------------------------------------------------------------- */

// Generic array types with known dimensions for C binding
%typemap(bindc, in="$typemap(bindc, $1_basetype), dimension($1_dim0), target", checkdim=1) FORTRAN_INTRINSIC_TYPE[ANY]
 "$typemap(bindc, $1_basetype), dimension($1_dim0)"
%typemap(bindc, in="$typemap(bindc, $1_basetype), dimension($1_dim1,$1_dim0), target", checkdim=1) FORTRAN_INTRINSIC_TYPE[ANY][ANY]
 "$typemap(bindc, $1_basetype), dimension($1_dim1,$1_dim0)"
%typemap(bindc, in="$typemap(bindc, $1_basetype), dimension($1_dim2,$1_dim1,$1_dim0), target", checkdim=1) FORTRAN_INTRINSIC_TYPE[ANY][ANY][ANY]
 "$typemap(bindc, $1_basetype), dimension($1_dim2,$1_dim1,$1_dim0)"

/* -------------------------------------------------------------------------
 * UNSIGNED FUNDAMENTAL TYPE
 * ------------------------------------------------------------------------- */

%fortran_apply_typemaps(FORTRAN_INTRINSIC_TYPE, FORTRAN_UNSIGNED_TYPE)
%typemap(in, noblock=1) const FORTRAN_UNSIGNED_TYPE& {
   $1 = ($1_ltype)($input);
}

/* -------------------------------------------------------------------------
 * VOID TYPES
 * ------------------------------------------------------------------------- */

%typemap(ctype, null="") void "void"
%typemap(out)            void ""
%typemap(imtype)         void ""
%typemap(ftype)          void ""
%typemap(fin)            void ""
%typemap(fout)           void ""
%typemap(bindc)          void ""

/* -------------------------------------------------------------------------
 * OPAQUE POINTERS
 *
 * A generic C pointer is treated as a value.
 * ------------------------------------------------------------------------- */

%fortran_intrinsic(void*, type(C_PTR))

/* -------------------------------------------------------------------------
 * FUNDAMENTAL TYPES
 * ------------------------------------------------------------------------- */

// Fundamental ISO-C binding types
%fortran_intrinsic(signed char, integer(C_SIGNED_CHAR))
%fortran_intrinsic(short      , integer(C_SHORT)      )
%fortran_intrinsic(int        , integer(C_INT)        )
%fortran_intrinsic(long       , integer(C_LONG)       )
%fortran_intrinsic(long long  , integer(C_LONG_LONG)  )
%fortran_intrinsic(size_t     , integer(C_SIZE_T)     )
%fortran_intrinsic(float      , real(C_FLOAT)         )
%fortran_intrinsic(double     , real(C_DOUBLE)        )
%fortran_intrinsic(char       , character(C_CHAR)     )

// Unsigned integer types
%fortran_unsigned(signed char     ,unsigned char      )
%fortran_unsigned(signed short    ,unsigned short     )
%fortran_unsigned(signed int      ,unsigned int       )
%fortran_unsigned(signed long     ,unsigned long      )
%fortran_unsigned(signed long long,unsigned long long )

/* -------------------------------------------------------------------------
 * LOGICAL (BOOLEAN) TYPE
 *
 * Due to differences in how Fortran and C treat logical values, it's not always
 * safe to treat C_BOOL and bool as compatible. Yay. So we pass integers
 * between the language and have the wrapper convert them. This also lets us
 * use the native fortran logical type instead of requiring users cast to
 * the special C_BOOL type.
 *
 * https://software.intel.com/en-us/forums/intel-fortran-compiler-for-linux-and-mac-os-x/topic/594856
 * http://www.fortran90.org/src/gotchas.html
 * 
 * ------------------------------------------------------------------------- */
// Treat bools like integers for C/IM types
%apply int { bool };
%typemap(in) bool
  "$1 = (*$input ? true : false);"
%typemap(out) bool
  "$result = ($1 ? 1 : 0);"
%typemap(ftype, in="logical, intent(in)") bool
  "logical"
%typemap(bindc, in="logical(C_BOOL), value") bool
  "logical(C_BOOL)"

// Special Fortran conversions for logical->c_int
%fortran_typemap_finout(bool)

// Treat const references like values
%apply bool { const bool& };
// ... except our 'in' typemap has to create a temporary
%typemap(in, noblock=1) const bool& (bool tempbool) {
  tempbool = (*$input ? true : false);
  $1 = &tempbool;
}

// Mutable references and arrays are treated like opaque pointers
%apply SWIGTYPE* { bool*, bool& };

/* -------------------------------------------------------------------------
 * FUNCTION POINTERS
 * ------------------------------------------------------------------------- */

%apply void* { SWIGTYPE (*)(ANY) } ;

%typemap(ctype) SWIGTYPE (*)(ANY)
  "$1_ltype"
%typemap(imtype, in="type(C_FUNPTR), value") SWIGTYPE (*)(ANY)
  "type(C_FUNPTR)"
%typemap(ftype, in="type(C_FUNPTR), intent(in), value") SWIGTYPE (*)(ANY)
  "type(C_FUNPTR)"
%typemap(bindc, in="type(C_FUNPTR), value") SWIGTYPE (*)(ANY)
  "type(C_FUNPTR)"

%apply SWIGTYPE (*)(ANY) { SWIGTYPE (* const)(ANY) } ;

/* -------------------------------------------------------------------------
 * TYPE CHECKING
 * ------------------------------------------------------------------------- */

// Type checking isn't used for Fortran but is required for unit tests
%typemap(typecheck, precedence=0) SWIGTYPE
  ""
%typemap(typecheck) char* = SWIGTYPE;

%typemap(throws, noblock=1) SWIGTYPE {
  SWIG_exception_impl("$decl", SWIG_RuntimeError, "C++ $1_type exception thrown", return $null);
}
