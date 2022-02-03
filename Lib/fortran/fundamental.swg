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
  logical, intent(in) :: finp
  integer(kind=C_INT), intent(out) :: iminp
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
  integer(kind=C_INT), intent(in) :: imout
  logical, intent(out) :: fout
  fout = (imout /= 0)
end subroutine
}

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


/* -------------------------------------------------------------------------
 * MACROS
 * ------------------------------------------------------------------------- */
/*!
 * \def %fortran_typemap_finout
 */
%define %fortran_typemap_finout(CPPTYPE, MATCHTYPE)
  // Typemap for converting to array wrapper
  %typemap(fin, fragment="SWIG_fin"{CPPTYPE}, noblock=1) MATCHTYPE {
  call %fortrantm(fin, CPPTYPE)($input, $1)
  }
  %typemap(fout, fragment="SWIG_fout"{CPPTYPE}, noblock=1) MATCHTYPE {
  call %fortrantm(fout, CPPTYPE)($1, $result)
  }
  %typemap(fdirectorin, fragment="SWIG_fout"{CPPTYPE}, noblock=1) MATCHTYPE {
  call %fortrantm(fout, CPPTYPE)($input, $1)
  }
  %typemap(fdirectorout, fragment="SWIG_fin"{CPPTYPE}, noblock=1) MATCHTYPE {
  call %fortrantm(fin, CPPTYPE)($1, $result)
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
 *
 * Note regarding array translation:
 *
 * Fortran proxy translation code: convert from ftype $input to imtype $1
 * Note that we take the address of the first element instead of the array,
 * because nonallocatable deferred-size arrays *cannot* be referenced in
 * standard F2003. This is because they might be slices of other arrays
 * (noncontiguous). It is the caller's responsibility to ensure only
 * contiguous arrays are passed. Conceivably we could improve this to use
 * strided access by also passing c_loc($input(2)) and doing pointer
 * arithmetic.
 * TODO: use the "CONTIGUOUS" attribute if f2008 is being used to guarantee
 * that we can get the C location of the input array directly.
 *
 */
%define %fortran_intrinsic(CTYPE, FTYPE, FKIND)
  %fortran_apply_typemaps(FORTRAN_INTRINSIC_TYPE, CTYPE)
  
  // Regular values are passed as pointers and returned by value
  %typemap(ctype, in="const " #CTYPE "*") CTYPE
   %{CTYPE%}
  %typemap(imtype, in=#FTYPE "(" #FKIND "), intent(in)") CTYPE
   %{FTYPE(FKIND)%}
  %typemap(ftype, in=#FTYPE "(" #FKIND "), intent(in)") CTYPE
   %{FTYPE(FKIND)%}
  %typemap(bindc, in=#FTYPE "(" #FKIND "), intent(in), value", kind=#FKIND,
           fortranconst=#FTYPE "(" #FKIND ")") CTYPE
   %{FTYPE(FKIND)%}
  %typemap(in) CTYPE = FORTRAN_INTRINSIC_TYPE;
  %typemap(out) CTYPE = FORTRAN_INTRINSIC_TYPE;
  %typemap(fin) CTYPE = FORTRAN_INTRINSIC_TYPE;
  %typemap(fout) CTYPE = FORTRAN_INTRINSIC_TYPE;

  %typemap(fin) CTYPE = FORTRAN_INTRINSIC_TYPE;
  %typemap(fout) CTYPE = FORTRAN_INTRINSIC_TYPE;

  %typemap(directorin) CTYPE = FORTRAN_INTRINSIC_TYPE;
  %typemap(directorout) CTYPE = FORTRAN_INTRINSIC_TYPE;
  %typemap(fdirectorin) CTYPE = FORTRAN_INTRINSIC_TYPE;
  %typemap(fdirectorout) CTYPE = FORTRAN_INTRINSIC_TYPE;

  %typemap(bindc) CTYPE* = FORTRAN_INTRINSIC_TYPE*;

  // Fragment for converting array to array wrapper. This needs the intermediate step of assigning the first element to an array pointer to be compatible with
  // ISO C.
  %fragment("SWIG_fin"{CTYPE[]}, "fsubprograms", fragment="SwigArrayWrapper_f", noblock=1)
{subroutine %fortrantm(fin, CTYPE[])(finp, iminp)
  use, intrinsic :: ISO_C_BINDING
  FTYPE(FKIND), dimension(:), intent(in), target :: finp
  type(SwigArrayWrapper), intent(out) :: iminp
  integer(C_SIZE_T) :: sz
  FTYPE(FKIND), pointer :: imtemp

  sz = size(finp, kind=C_SIZE_T)
  if (sz > 0_c_size_t) then
    imtemp => finp(1)
    iminp%data = c_loc(imtemp)
  else
    iminp%data = c_null_ptr
  end if
  iminp%size = sz
end subroutine}

  // Fragment for converting array wrapper to array
  %fragment("SWIG_fout"{CTYPE[]}, "fsubprograms", noblock=1)
  {subroutine %fortrantm(fout, CTYPE[])(imout, fout)
  use, intrinsic :: ISO_C_BINDING
  type(SwigArrayWrapper), intent(in) :: imout
  FTYPE(FKIND), dimension(:), pointer, intent(out) :: fout

  if (imout%size > 0) then
    call c_f_pointer(imout%data, fout, [imout%size])
  else
    fout => NULL()
  endif
end subroutine}

  // Define proxy code typemaps for an array of this type
  %fortran_typemap_finout(CTYPE[], CTYPE ARRAY[])
  %typemap(fargout, fragment="SWIG_fout"{CTYPE[]}, noblock=1) CTYPE ARRAY[] {
  call %fortrantm(fout, CTYPE[])($1, $input)
  }
  %typemap(fargout) CTYPE const ARRAY[] = CTYPE ARRAY[];
%enddef

/*!
 * \def %fortran_unsigned
 * \brief Apply typemaps for treating signed/unsigned variables
 */
%define %fortran_unsigned(SRCTYPE, DSTTYPE)
  // Copy value properties and array properties from source type
  %apply SRCTYPE { DSTTYPE };

  %fortran_apply_typemaps(FORTRAN_UNSIGNED_TYPE, DSTTYPE)

  %typemap(bindc) DSTTYPE* = FORTRAN_INTRINSIC_TYPE*;
  %typemap(bindc) const DSTTYPE* = const FORTRAN_INTRINSIC_TYPE*;

  %typemap(out, noblock=1) DSTTYPE& {
     $result = (SRCTYPE*)($1);
  }

  %typemap(fin) DSTTYPE ARRAY[] = SRCTYPE ARRAY[];
  %typemap(fout) DSTTYPE ARRAY[] = SRCTYPE ARRAY[];
  %typemap(fargout) DSTTYPE ARRAY[] = SRCTYPE ARRAY[];
  %typemap(fargout) DSTTYPE const ARRAY[] = SRCTYPE const ARRAY[];
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
 in
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
%typemap(in) FORTRAN_INTRINSIC_TYPE "$1 = ($1_ltype)(*$input);"
%typemap(out) FORTRAN_INTRINSIC_TYPE "$result = ($1_ltype)($1);"
%typemap(fin) FORTRAN_INTRINSIC_TYPE "$1 = $input"
%typemap(fout) FORTRAN_INTRINSIC_TYPE "$result = $1"

%typemap(directorin, noblock=1) FORTRAN_INTRINSIC_TYPE ($1_ltype temp)
%{temp = $1;
$input = &temp;%}
%typemap(directorout) FORTRAN_INTRINSIC_TYPE "$result = $1;"
%typemap(fdirectorin) FORTRAN_INTRINSIC_TYPE "$1 = $input"
%typemap(fdirectorout) FORTRAN_INTRINSIC_TYPE "$result = $1"

// Pointers can be directly bound
%typemap(bindc, in="$typemap(imtype, $*1_ltype)") FORTRAN_INTRINSIC_TYPE*
  "type(C_PTR)"
%typemap(bindc, in="$typemap(imtype, $*1_ltype), intent(in)") const FORTRAN_INTRINSIC_TYPE*
  "type(C_PTR)"

// Mutable references are passed by pointers as arguments, but they're
// *returned* as actual pointers (becoming Fortran pointers).
%typemap(ctype) FORTRAN_INTRINSIC_TYPE&
  "$typemap(ctype, $*1_ltype)*"
%typemap(imtype, in="type(C_PTR), value") FORTRAN_INTRINSIC_TYPE&
  "type(C_PTR)"
%typemap(ftype, in="$typemap(ftype, $*1_ltype), target, intent(inout)") FORTRAN_INTRINSIC_TYPE&
  "$typemap(ftype, $*1_ltype), pointer"
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

// Treat rvalue references as const refererences (i.e. copy the result)
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
%typemap(directorin)     void ""
%typemap(bindc)          void ""

/* -------------------------------------------------------------------------
 * FUNDAMENTAL TYPES
 * ------------------------------------------------------------------------- */

// Fundamental ISO-C binding types
%fortran_intrinsic(signed char, integer  , C_SIGNED_CHAR)
%fortran_intrinsic(short      , integer  , C_SHORT)
%fortran_intrinsic(int        , integer  , C_INT)
%fortran_intrinsic(long       , integer  , C_LONG)
%fortran_intrinsic(long long  , integer  , C_LONG_LONG)
%fortran_intrinsic(size_t     , integer  , C_SIZE_T)
%fortran_intrinsic(float      , real     , C_FLOAT)
%fortran_intrinsic(double     , real     , C_DOUBLE)
%fortran_intrinsic(char       , character, C_CHAR)

// Unsigned integer types
%fortran_unsigned(signed char     ,unsigned char      )
%fortran_unsigned(signed short    ,unsigned short     )
%fortran_unsigned(signed int      ,unsigned int       )
%fortran_unsigned(signed long     ,unsigned long      )
%fortran_unsigned(signed long long,unsigned long long )

// Pointer type
%fortran_intrinsic(void*, type, C_PTR)

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

// Define special fin/fout typemaps for logical<->c_int
%fortran_typemap_finout(bool, bool)

%typemap(directorin, noblock=1) bool (int temp)
%{temp = $1 ? 1 : 0;
$input = &temp;%}
%typemap(directorout) bool "$result = (bool)$1;"

// Treat const references like values
%apply bool { const bool& };
// ... except our 'in' typemap has to create a temporary
%typemap(in, noblock=1) const bool& (bool tempbool) {
  tempbool = (*$input ? true : false);
  $1 = &tempbool;
}

// Mutable references are treated like opaque pointers
%apply SWIGTYPE* { bool& };

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
