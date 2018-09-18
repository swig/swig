/* -------------------------------------------------------------------------
 * fundamental.swg
 *
 * Define fundamental/primitive/built-in types that override the SWIGTYPE
 * class definitions. Since most of the scalar types and their derivatives are
 * treated identically, we define typemaps for a fake type "FUNDTYPE" and
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
%fragment("SWIG_logical_to_int_f", "fwrapper", noblock=1) {
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

%fragment("SWIG_int_to_logical_f", "fwrapper", noblock=1) {
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
 * \def FORT_APPLY_TYPEMAPS
 * \brief Copy fundamental typemaps to the given type.
 */
%define FORT_APPLY_TYPEMAPS(SRCTYPE, DSTTYPE)
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
 * \def FORT_FUND_TYPEMAP
 * \brief Add typemaps for fundamental ISO-C compatible types.
 */
%define FORT_FUND_TYPEMAP(CTYPE, FTYPE)
  FORT_APPLY_TYPEMAPS(FUNDTYPE, CTYPE)
  
  // Regular values are passed as pointers and returned by value
  %typemap(ctype, in={const CTYPE*}) CTYPE
   %{CTYPE%}
  %typemap(imtype, in={FTYPE, intent(in)}) CTYPE
   %{FTYPE%}
  %typemap(ftype, in={FTYPE, intent(in)}) CTYPE
   %{FTYPE%}
  %typemap(bindc, in={FTYPE, value}) CTYPE
   %{FTYPE%}
  %typemap(in) CTYPE = FUNDTYPE;
  %typemap(out) CTYPE = FUNDTYPE;
  %typemap(fin) CTYPE = FUNDTYPE;
  %typemap(fout) CTYPE = FUNDTYPE;

  // XXX I'd like to do this as FUNDTYPE, but because $1_basetype doesn't work properly, and there's no way to do `$**1_ltype`, we have to explicitly add
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
 * \def FORT_UNSIGNED_TYPEMAP
 * \brief Typemaps for treating signed/unsigned variables
 */
%define FORT_UNSIGNED_TYPEMAP(SRCTYPE, DSTTYPE)
  %apply SRCTYPE { DSTTYPE };
  FORT_APPLY_TYPEMAPS(UFUNDTYPE, DSTTYPE)

  %typemap(out, noblock=1)
    DSTTYPE*, DSTTYPE&, DSTTYPE[], DSTTYPE[ANY],
    const DSTTYPE*, const DSTTYPE&, const DSTTYPE[], const DSTTYPE[ANY] {
     $result = %reinterpret_cast($1, SRCTYPE*);
  }
%enddef

/*!
 * \def FORT_BINDC_ARRAY_TYPEMAP
 * \brief Generate array typemaps for the given dimensions
 */
%define FORT_BINDC_ARRAY_TYPEMAP(CPPTYPE, FDIMS...)
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
 * (see the %fortranbindc_type feature) can also be made interoperable.
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
 *   Note that $1_ltype is the same for FUNDTYPE*, FUNDTYPE&, FUNDTYPE[],
 *   and FUNDTYPE[ANY], and the const versions of those.
 */

// Fundamental types
%typemap(in, noblock=1) FUNDTYPE {
  $1 = %static_cast(*$input, $1_ltype);
}
%typemap(out, noblock=1) FUNDTYPE {
  $result = %static_cast($1, $1_ltype);
}
%typemap(fin) FUNDTYPE
  "$1 = $input"
%typemap(fout) FUNDTYPE
  "$result = $1"

// Mutable references are passed by pointers as arguments, but they're
// *returned* as actual pointers (becoming Fortran pointers).
%typemap(ctype) FUNDTYPE*
  "$typemap(ctype, $*1_ltype)*"
%typemap(imtype, in="type(C_PTR), value") FUNDTYPE*
  "type(C_PTR)"
%typemap(ftype, in="$typemap(ftype, $*1_ltype), target, intent(inout)") FUNDTYPE*
  "$typemap(ftype, $*1_ltype), pointer"
%typemap(bindc, in="$typemap(imtype, $*1_ltype)") FUNDTYPE*
  "type(C_PTR)"
%typemap(in, noblock=1) FUNDTYPE* {
   $1 = %reinterpret_cast($input, $1_ltype);
}
%typemap(out) FUNDTYPE*
  "$result = $1;"
%typemap(fin) FUNDTYPE*
  "$1 = c_loc($input)"
%typemap(fout) FUNDTYPE*
  "call c_f_pointer($1, $result)"

%apply FUNDTYPE* { const FUNDTYPE* };
%typemap(ctype) const FUNDTYPE*
  "const $typemap(ctype, $*1_ltype)*"
%typemap(bindc, in="$typemap(imtype, $*1_ltype), intent(in)") const FUNDTYPE*
  "type(C_PTR)"
%typemap(in, noblock=1) const FUNDTYPE* {
  $1 = %const_cast($input, $1_ltype);
}
%typemap(out, noblock=1) const FUNDTYPE* {
  $result = %const_cast($1, $1_ltype);
}

// Mutable references are treated as mutable pointers
%apply FUNDTYPE* { FUNDTYPE& }

// We treat const references as values for fundamental types
// Since ctype/imtype/ftype aren't defined for 'FUNDTYPE' (just for each fundamental type), use $typemap to retrieve the corresponding values.
%apply FUNDTYPE { const FUNDTYPE& };
%typemap(ctype, in="const $typemap(ctype, $*1_ltype)*") const FUNDTYPE&
  "$typemap(ctype, $*1_ltype)"
%typemap(imtype, in="$typemap(imtype, $*1_ltype), intent(in)") const FUNDTYPE&
  "$typemap(imtype, $*1_ltype)"
%typemap(ftype) const FUNDTYPE&
  "$typemap(ftype, $*1_ltype)"
%typemap(in, noblock=1) const FUNDTYPE& ($*1_ltype temp) {
  temp = %static_cast(*$input, $*1_ltype);
  $1 = &temp;
}
%typemap(out) const FUNDTYPE& 
  "$result = *$1;"

// Unspecified-size array inputs should appear as deferred arrays; but since we can't provide a size for the output, we assign a size of 1 for now.
%apply FUNDTYPE* { FUNDTYPE[] }
%typemap(ftype, in="$typemap(ftype, $*1_ltype), dimension(*), target, intent(inout)", checkdim=1) FUNDTYPE[]
  "$typemap(ftype, $*1_ltype), dimension(:), pointer"
%typemap(fin, checkdim=1) FUNDTYPE[]
  "$1 = c_loc($input(1))" // (1): see forarray.swg
%typemap(fout, checkdim=1) FUNDTYPE[]
  "call c_f_pointer($1, $result, [1])"
 
%apply const FUNDTYPE* { const FUNDTYPE[] }
%typemap(ftype, in="$typemap(ftype, $*1_ltype), dimension(*), target, intent(in)", checkdim=1) const FUNDTYPE[]
  "$typemap(ftype, $*1_ltype), dimension(:), pointer"
%typemap(fin) const FUNDTYPE[] = FUNDTYPE[];
%typemap(fout) const FUNDTYPE[] = FUNDTYPE[];
  
// Fixed-sized arrays can be treated natively
%apply FUNDTYPE[] { FUNDTYPE[ANY] }
%typemap(ftype, in="$typemap(ftype, $*1_ltype), dimension($1_dim0), target, intent(inout)", checkdim=1) FUNDTYPE[ANY]
  "$typemap(ftype, $*1_ltype), dimension(:), pointer"
%typemap(fout, checkdim=1) FUNDTYPE[ANY]
  "call c_f_pointer($1, $result, [$1_dim0])"

// Use correct intent for const fixed-size arrays
%apply const FUNDTYPE[] { const FUNDTYPE[ANY] }
%typemap(ftype, in="$typemap(ftype, $*1_ltype), dimension($1_dim0), target, intent(in)", checkdim=1) const FUNDTYPE[ANY]
  "$typemap(ftype, $*1_ltype), dimension(:), pointer"
%typemap(fout) const FUNDTYPE[ANY] = FUNDTYPE[ANY];
  
// Treat rvalue references as values
%apply const FUNDTYPE& { FUNDTYPE&& };

// Const references to mutable pointers
%apply FUNDTYPE* { FUNDTYPE *const & };
%typemap(in, noblock=1) FUNDTYPE *const & ($*1_ltype temp)
  {temp = %const_cast($input, $*1_ltype);
   $1 = &temp;}
%typemap(out) FUNDTYPE *const &
  "$result = *$1;"
  
// Const references to const pointers
%apply const FUNDTYPE* { const FUNDTYPE *const & };

/* -------------------------------------------------------------------------
 * ARRAY TYPES
 * ------------------------------------------------------------------------- */

// Generic array types with unknown dimensions for C binding
FORT_BINDC_ARRAY_TYPEMAP(FUNDTYPE[],           dimension(*))
FORT_BINDC_ARRAY_TYPEMAP(FUNDTYPE[ANY],        dimension($1_dim0))
FORT_BINDC_ARRAY_TYPEMAP(SWIGTYPE[][ANY],      dimension($1_dim1,*))
FORT_BINDC_ARRAY_TYPEMAP(SWIGTYPE[][ANY][ANY], dimension($1_dim2,$1_dim1,*)) 

/* -------------------------------------------------------------------------
 * UNSIGNED FUNDAMENTAL TYPE
 * ------------------------------------------------------------------------- */

FORT_APPLY_TYPEMAPS(FUNDTYPE, UFUNDTYPE)
%typemap(in, noblock=1) const UFUNDTYPE* {
   $1 = ($1_ltype)($input);
}
%apply UFUNDTYPE* { UFUNDTYPE& };
%apply const UFUNDTYPE* { const UFUNDTYPE& };

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

%apply FUNDTYPE* { void* } ;

%typemap(ctype) void*
  "void*"
%typemap(imtype) void* = FUNDTYPE*;
%typemap(ftype) void*
  "type(C_PTR)"
%typemap(bindc, in="type(C_PTR), value") void*
  "type(C_PTR)"

%typemap(in, noblock=1) void* {
  $1 = %reinterpret_cast($input, $1_ltype);
}
%typemap(fin) void* = FUNDTYPE;
%typemap(fout) void* = FUNDTYPE;

%apply void* { const void* } ;
%typemap(in, noblock=1) const void* {
  $1 = ($1_ltype)($input);
}

/* -------------------------------------------------------------------------
 * HANDLES
 *
 * A 'void**' looks like a FUNDTYPE* where FUNDTYPE is 'void*' (aka C_PTR)
 * ------------------------------------------------------------------------- */

%apply void* { SWIGTYPE**};
%typemap(ftype, in="type(C_PTR), target, intent(inout)") SWIGTYPE**
  "type(C_PTR), pointer"
%typemap(fin) SWIGTYPE** = FUNDTYPE*;
%typemap(fout) SWIGTYPE** = FUNDTYPE*;
%apply SWIGTYPE** { SWIGTYPE*&, SWIGTYPE *const* };

%apply const void* { const SWIGTYPE**};
%typemap(ftype, in="type(C_PTR), target, intent(in)") const SWIGTYPE**
  "type(C_PTR), pointer"
%typemap(fin) const SWIGTYPE** = const FUNDTYPE*;
%typemap(fout) const SWIGTYPE** = const FUNDTYPE*;
%apply const SWIGTYPE** { const SWIGTYPE*&, const SWIGTYPE *const*,
SWIGTYPE ** const, SWIGTYPE **const &};

/* -------------------------------------------------------------------------
 * FUNDAMENTAL TYPES
 * ------------------------------------------------------------------------- */

// Fundamental ISO-C binding types
FORT_FUND_TYPEMAP(signed char, integer(C_SIGNED_CHAR))
FORT_FUND_TYPEMAP(short      , integer(C_SHORT)      )
FORT_FUND_TYPEMAP(int        , integer(C_INT)        )
FORT_FUND_TYPEMAP(long       , integer(C_LONG)       )
FORT_FUND_TYPEMAP(long long  , integer(C_LONG_LONG)  )
FORT_FUND_TYPEMAP(size_t     , integer(C_SIZE_T)     )
FORT_FUND_TYPEMAP(float      , real(C_FLOAT)         )
FORT_FUND_TYPEMAP(double     , real(C_DOUBLE)        )
FORT_FUND_TYPEMAP(char       , character(C_CHAR)     )

// Unsigned integer types
FORT_UNSIGNED_TYPEMAP(signed char     ,unsigned char      )
FORT_UNSIGNED_TYPEMAP(signed short    ,unsigned short     )
FORT_UNSIGNED_TYPEMAP(signed int      ,unsigned int       )
FORT_UNSIGNED_TYPEMAP(signed long     ,unsigned long      )
FORT_UNSIGNED_TYPEMAP(signed long long,unsigned long long )

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
