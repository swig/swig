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
%fragment("SWIG_logical_to_int_f", "fsubprograms", noblock=1) {
function SWIG_logical_to_int(inp) &
    result(out)
  use, intrinsic :: ISO_C_BINDING
  logical, intent(IN) :: inp
  integer(kind=C_INT) :: out
  if (inp .eqv. .true.) then
    out = 1
  else
    out = 0
  end if
end function
}

%fragment("SWIG_int_to_logical_f", "fsubprograms", noblock=1) {
function SWIG_int_to_logical(inp) &
    result(out)
  use, intrinsic :: ISO_C_BINDING
  integer(kind=C_INT), intent(IN) :: inp
  logical :: out
  if (inp /= 0) then
    out = .true.
  else
    out = .false.
  end if
end function
}

/* -------------------------------------------------------------------------
 * MACROS
 * ------------------------------------------------------------------------- */
/*!
 * \def %fortran_apply_typemaps
 * \brief Copy fundamental typemaps to the given type.
 */
%define %fortran_apply_typemaps(SRCTYPE, DSTTYPE)
  // Copy all relevant typemaps
  %apply       SRCTYPE*        {       DSTTYPE* };
  %apply const SRCTYPE*        { const DSTTYPE* };
  %apply       SRCTYPE&        {       DSTTYPE& };
  %apply const SRCTYPE&        { const DSTTYPE& };
  %apply       SRCTYPE[]       {       DSTTYPE[] };
  %apply const SRCTYPE[]       { const DSTTYPE[] };
  %apply       SRCTYPE[ANY]    {       DSTTYPE[ANY] };
  %apply const SRCTYPE[ANY]    { const DSTTYPE[ANY] };
  %apply       SRCTYPE* const& {       DSTTYPE* const& };
  %apply const SRCTYPE* const& { const DSTTYPE* const& };
  %apply       SRCTYPE&&       {       DSTTYPE&&};
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

  // XXX I'd like to do this as FORTRAN_INTRINSIC_TYPE, but because $1_basetype doesn't work properly, and there's no way to do `$**1_ltype`, we have to explicitly add
  // these here.
  %typemap(ftype, in={FTYPE, target, intent(inout)}, noblock=1) CTYPE *const & {
    FTYPE, pointer
  }
  %typemap(ctype, noblock=1) CTYPE *const & {
    const CTYPE*
  }
  %apply CTYPE *const & { const CTYPE *const & };
%enddef

/*!
 * \def %fortran_apply_unsigned
 * \brief Apply typemaps for treating signed/unsigned variables
 */
%define %fortran_apply_unsigned(SRCTYPE, DSTTYPE)
  %apply SRCTYPE { DSTTYPE };
  %fortran_apply_typemaps(FORTRAN_UNSIGNED_TYPE, DSTTYPE)

  %typemap(out, noblock=1)
    DSTTYPE*, DSTTYPE&, DSTTYPE[], DSTTYPE[ANY],
    const DSTTYPE*, const DSTTYPE&, const DSTTYPE[], const DSTTYPE[ANY] {
     $result = %reinterpret_cast($1, SRCTYPE*);
  }
%enddef

/*!
 * \def %fortran_bindc_array
 * \brief Generate array typemaps for the given dimensions
 */
%define %fortran_bindc_array(CPPTYPE, FDIMS...)
  #define FARRTYPE $typemap(imtype, $1_basetype), FDIMS
  %typemap(bindc, in={FARRTYPE, intent(inout)}, checkdim=1, noblock=1) CPPTYPE
   {FARRTYPE}
  %typemap(bindc, in={FARRTYPE, intent(in)}, checkdim=1, noblock=1) const CPPTYPE
   {FARRTYPE}
  #undef FARRTYPE
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
  $1 = %static_cast(*$input, $1_ltype);
}
%typemap(out, noblock=1) FORTRAN_INTRINSIC_TYPE {
  $result = %static_cast($1, $1_ltype);
}
%typemap(fin) FORTRAN_INTRINSIC_TYPE
  "$1 = $input"
%typemap(fout) FORTRAN_INTRINSIC_TYPE
  "$result = $1"

// Mutable references are passed by pointers as arguments, but they're
// *returned* as actual pointers (becoming Fortran pointers).
%typemap(ctype) FORTRAN_INTRINSIC_TYPE*
  "$typemap(ctype, $*1_ltype)*"
%typemap(imtype, in="type(C_PTR), value") FORTRAN_INTRINSIC_TYPE*
  "type(C_PTR)"
%typemap(ftype, in="$typemap(ftype, $*1_ltype), target, intent(inout)") FORTRAN_INTRINSIC_TYPE*
  "$typemap(ftype, $*1_ltype), pointer"
%typemap(bindc, in="$typemap(imtype, $*1_ltype)") FORTRAN_INTRINSIC_TYPE*
  "type(C_PTR)"
%typemap(in, noblock=1) FORTRAN_INTRINSIC_TYPE* {
   $1 = %reinterpret_cast($input, $1_ltype);
}
%typemap(out) FORTRAN_INTRINSIC_TYPE*
  "$result = $1;"
%typemap(fin) FORTRAN_INTRINSIC_TYPE*
  "$1 = c_loc($input)"
%typemap(fout) FORTRAN_INTRINSIC_TYPE*
  "call c_f_pointer($1, $result)"

%apply FORTRAN_INTRINSIC_TYPE* { const FORTRAN_INTRINSIC_TYPE* };
%typemap(ctype) const FORTRAN_INTRINSIC_TYPE*
  "const $typemap(ctype, $*1_ltype)*"
%typemap(bindc, in="$typemap(imtype, $*1_ltype), intent(in)") const FORTRAN_INTRINSIC_TYPE*
  "type(C_PTR)"
%typemap(in, noblock=1) const FORTRAN_INTRINSIC_TYPE* {
  $1 = %const_cast($input, $1_ltype);
}
%typemap(out, noblock=1) const FORTRAN_INTRINSIC_TYPE* {
  $result = %const_cast($1, $1_ltype);
}

// Mutable references are treated as mutable pointers
%apply FORTRAN_INTRINSIC_TYPE* { FORTRAN_INTRINSIC_TYPE& }

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
  temp = %static_cast(*$input, $*1_ltype);
  $1 = &temp;
}
%typemap(out) const FORTRAN_INTRINSIC_TYPE& 
  "$result = *$1;"

// Unspecified-size array inputs should appear as deferred arrays; but since we can't provide a size for the output, we assign a size of 1 for now.
%apply FORTRAN_INTRINSIC_TYPE* { FORTRAN_INTRINSIC_TYPE[] }
%typemap(ftype, in="$typemap(ftype, $*1_ltype), dimension(*), target, intent(inout)", checkdim=1) FORTRAN_INTRINSIC_TYPE[]
  "$typemap(ftype, $*1_ltype), dimension(:), pointer"
%typemap(fin, checkdim=1) FORTRAN_INTRINSIC_TYPE[]
  "$1 = c_loc($input(1))" // (1): see fortranarray.swg
%typemap(fout, checkdim=1) FORTRAN_INTRINSIC_TYPE[]
  "call c_f_pointer($1, $result, [1])"
 
%apply const FORTRAN_INTRINSIC_TYPE* { const FORTRAN_INTRINSIC_TYPE[] }
%typemap(ftype, in="$typemap(ftype, $*1_ltype), dimension(*), target, intent(in)", checkdim=1) const FORTRAN_INTRINSIC_TYPE[]
  "$typemap(ftype, $*1_ltype), dimension(:), pointer"
%typemap(fin) const FORTRAN_INTRINSIC_TYPE[] = FORTRAN_INTRINSIC_TYPE[];
%typemap(fout) const FORTRAN_INTRINSIC_TYPE[] = FORTRAN_INTRINSIC_TYPE[];
  
// Fixed-sized arrays can be treated natively
%apply FORTRAN_INTRINSIC_TYPE[] { FORTRAN_INTRINSIC_TYPE[ANY] }
%typemap(ftype, in="$typemap(ftype, $*1_ltype), dimension($1_dim0), target, intent(inout)", checkdim=1) FORTRAN_INTRINSIC_TYPE[ANY]
  "$typemap(ftype, $*1_ltype), dimension(:), pointer"
%typemap(fout, checkdim=1) FORTRAN_INTRINSIC_TYPE[ANY]
  "call c_f_pointer($1, $result, [$1_dim0])"

// Use correct intent for const fixed-size arrays
%apply const FORTRAN_INTRINSIC_TYPE[] { const FORTRAN_INTRINSIC_TYPE[ANY] }
%typemap(ftype, in="$typemap(ftype, $*1_ltype), dimension($1_dim0), target, intent(in)", checkdim=1) const FORTRAN_INTRINSIC_TYPE[ANY]
  "$typemap(ftype, $*1_ltype), dimension(:), pointer"
%typemap(fout) const FORTRAN_INTRINSIC_TYPE[ANY] = FORTRAN_INTRINSIC_TYPE[ANY];
  
// Treat rvalue references as values
%apply const FORTRAN_INTRINSIC_TYPE& { FORTRAN_INTRINSIC_TYPE&& };

// Const references to mutable pointers
%apply FORTRAN_INTRINSIC_TYPE* { FORTRAN_INTRINSIC_TYPE *const & };
%typemap(in, noblock=1) FORTRAN_INTRINSIC_TYPE *const & ($*1_ltype temp)
  {temp = %const_cast($input, $*1_ltype);
   $1 = &temp;}
%typemap(out) FORTRAN_INTRINSIC_TYPE *const &
  "$result = *$1;"
  
// Const references to const pointers
%apply const FORTRAN_INTRINSIC_TYPE* { const FORTRAN_INTRINSIC_TYPE *const & };

/* -------------------------------------------------------------------------
 * ARRAY TYPES
 * ------------------------------------------------------------------------- */

// Generic array types with unknown dimensions for C binding
%fortran_bindc_array(FORTRAN_INTRINSIC_TYPE[],           dimension(*))
%fortran_bindc_array(FORTRAN_INTRINSIC_TYPE[ANY],        dimension($1_dim0))
%fortran_bindc_array(SWIGTYPE[][ANY],      dimension($1_dim1,*))
%fortran_bindc_array(SWIGTYPE[][ANY][ANY], dimension($1_dim2,$1_dim1,*)) 

/* -------------------------------------------------------------------------
 * UNSIGNED FUNDAMENTAL TYPE
 * ------------------------------------------------------------------------- */

%fortran_apply_typemaps(FORTRAN_INTRINSIC_TYPE, FORTRAN_UNSIGNED_TYPE)
%typemap(in, noblock=1) const FORTRAN_UNSIGNED_TYPE* {
   $1 = ($1_ltype)($input);
}
%apply FORTRAN_UNSIGNED_TYPE* { FORTRAN_UNSIGNED_TYPE& };
%apply const FORTRAN_UNSIGNED_TYPE* { const FORTRAN_UNSIGNED_TYPE& };

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

%apply FORTRAN_INTRINSIC_TYPE* { void* } ;

%typemap(ctype) void*
  "void*"
%typemap(imtype) void* = FORTRAN_INTRINSIC_TYPE*;
%typemap(ftype) void*
  "type(C_PTR)"
%typemap(bindc, in="type(C_PTR), value") void*
  "type(C_PTR)"

%typemap(in, noblock=1) void* {
  $1 = %reinterpret_cast($input, $1_ltype);
}
%typemap(fin) void* = FORTRAN_INTRINSIC_TYPE;
%typemap(findecl, match="fin") void* "";
%typemap(fout) void* = FORTRAN_INTRINSIC_TYPE;
%typemap(foutdecl, match="fout") void* "";

%apply void* { const void* } ;
%typemap(in, noblock=1) const void* {
  $1 = ($1_ltype)($input);
}

/* -------------------------------------------------------------------------
 * HANDLES
 *
 * A 'void**' looks like a FORTRAN_INTRINSIC_TYPE* where FORTRAN_INTRINSIC_TYPE is 'void*' (aka C_PTR)
 * ------------------------------------------------------------------------- */

%apply void* { SWIGTYPE** };
%typemap(ftype, in="type(C_PTR), target, intent(inout)") SWIGTYPE**
  "type(C_PTR), pointer"
%typemap(fin) SWIGTYPE** = FORTRAN_INTRINSIC_TYPE*;
%typemap(fout) SWIGTYPE** = FORTRAN_INTRINSIC_TYPE*;
%apply SWIGTYPE** { SWIGTYPE*&, SWIGTYPE *const* };

%apply const void* { const SWIGTYPE** };
%typemap(ftype, in="type(C_PTR), target, intent(in)") const SWIGTYPE**
  "type(C_PTR), pointer"
%typemap(fin) const SWIGTYPE** = const FORTRAN_INTRINSIC_TYPE*;
%typemap(fout) const SWIGTYPE** = const FORTRAN_INTRINSIC_TYPE*;
%apply const SWIGTYPE** { const SWIGTYPE*&, const SWIGTYPE *const*,
SWIGTYPE ** const, SWIGTYPE **const &};

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
%fortran_apply_unsigned(signed char     ,unsigned char      )
%fortran_apply_unsigned(signed short    ,unsigned short     )
%fortran_apply_unsigned(signed int      ,unsigned int       )
%fortran_apply_unsigned(signed long     ,unsigned long      )
%fortran_apply_unsigned(signed long long,unsigned long long )

// TODO: provide optional typemap(check) code for unsigned/signed range

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
%typemap(ftype, in="logical, intent(in)") bool
  "logical"
%typemap(bindc, in="logical(C_BOOL), value") bool
  "logical(C_BOOL)"

%typemap(in) bool
  "$1 = (*$input ? true : false);"
%typemap(out) bool
  "$result = ($1 ? 1 : 0);"
%typemap(fin, fragment="SWIG_logical_to_int_f") bool
  "$1 = SWIG_logical_to_int($input)"
%typemap(fout, fragment="SWIG_int_to_logical_f") bool
  "$result = SWIG_int_to_logical($1)"

// Treat const references like values
%apply bool { const bool& };
// ... except our 'in' typemap has to create a temporary
%typemap(in, noblock=1) const bool& (bool tempbool) {
  tempbool = (*$input ? true : false);
  $1 = &tempbool;
}

// Mutable references and arrays are treated like opaque pointers
%apply void* { bool*, bool& };

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
