/* -------------------------------------------------------------------------
 * fundamental.swg
 * ------------------------------------------------------------------------- */

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
%fragment("SWIG_logical_to_int_f", "fwrapper", noblock="1") %{
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
%}

%fragment("SWIG_int_to_logical_f", "fwrapper", noblock="1") %{
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
%}

/* -------------------------------------------------------------------------
 * MACROS
 * ------------------------------------------------------------------------- */
%include <typemaps/swigmacros.swg>

/*!
 * \def FORT_SIMPLE_TYPEMAP
 * \brief Add typemaps where the C++ and C types are convertible, and
 * the intermediate Fortran typemaps are also directly convertible.
 *
 * - Arguments in Fortran are passed by pointer reference, and return
 * types are passed by value.
 * - Returning by const reference is automatically turned into return-by-value
 *  (this is the 'out=CTYPE' argument).
 * - Mutable references that are arguments get the 'inout' qualifier in Fortran,
 *  whereas values and const references are simply 'in'.
 * - Mutable references that are *return* values are passed as pointers, and on
 * the Fortan side these become 'pointer' types.
 * - Fixed-size arrays are passed as known-size array pointers, but otherwise
 *   they are treated as pointers to scalar data.
 */
%define FORT_SIMPLE_TYPEMAP(CPPTYPE, CTYPE, FTYPE)
  // Regular values are passed as pointers and returned by value
  %typemap(ctype, out="CTYPE") CPPTYPE
    "const CTYPE*"
  %typemap(in) CPPTYPE
    "$1 = *$input;"
  %typemap(out) CPPTYPE
    "$result = $1;"
  %typemap(imtype, in=FTYPE ", intent(in)") CPPTYPE
    FTYPE
  %typemap(ftype, out=FTYPE) CPPTYPE
    FTYPE ", intent(in)"
  %typemap(fin)  CPPTYPE
    "$1 = $input"
  %typemap(fout) CPPTYPE
    "$result = $1"

  // Mutable references are passed by pointers as arguments, but they're
  // *returned* as actual pointers (becoming Fortran pointers). Again we face
  // problems when these typemaps are "applied" to a different type. Ideally we
  // could check *at least* that the types are the same size...
  %typemap(ctype, out="CTYPE*") CPPTYPE*
    "CTYPE*"
  %typemap(in, noblock=1) CPPTYPE* {
    $1 = %reinterpret_cast($input, $1_ltype);
  }
  %typemap(out, noblock=1) CPPTYPE* {
    $result = %reinterpret_cast($1, CTYPE*);
  }
  %typemap(imtype, in="type(C_PTR), value") CPPTYPE*
    "type(C_PTR)"
  %typemap(ftype, out=FTYPE ", pointer") CPPTYPE*
    FTYPE ", target, intent(inout)"
  %typemap(fin)  CPPTYPE*
    "$1 = c_loc($input)"
  %typemap(fout) CPPTYPE*
    "call c_f_pointer($1, $result)"
  FORT_COPY_TYPEMAPS(CPPTYPE*, CPPTYPE* const);

  // Mutable references and arrays are treated just like pointers
  FORT_COPY_TYPEMAPS(CPPTYPE*, CPPTYPE&, CPPTYPE*&, CPPTYPE[], CPPTYPE[ANY]);
  // ...except that fixed-sized arrays can be treated natively
  %typemap(ftype, out=FTYPE ", dimension(:), pointer", checkdim=1) CPPTYPE[ANY]
    FTYPE ", dimension($1_dim0), target, intent(inout)"
  %typemap(fout, checkdim=1) CPPTYPE[ANY] %{
      call c_f_pointer($1, $result, [$1_dim0])
  %}

  // Const pointers also are treated like raw pointers for the most part,
  // except for some constness issues. (SWIG's temporary variables are
  // non-const, so we must const-cast.)
  %typemap(ctype, out="const CTYPE*") const CPPTYPE*
    "const CTYPE*"
  %typemap(in, noblock=1) const CPPTYPE* {
    $1 = %reinterpret_cast(%const_cast($input, CTYPE*), $1_ltype);
  }
  %typemap(out, noblock=1) const CPPTYPE* {
    $result = %const_cast(%reinterpret_cast($1, const CTYPE*), CTYPE*);
  }
  %typemap(imtype, in="type(C_PTR), value") const CPPTYPE*
    "type(C_PTR)"
  %typemap(ftype)  const CPPTYPE*    = CPPTYPE*;
  %typemap(fin)    const CPPTYPE*    = CPPTYPE*;
  %typemap(fout)   const CPPTYPE*    = CPPTYPE*;
  FORT_COPY_TYPEMAPS(const CPPTYPE*, const CPPTYPE* const);

  // We treat const references like value types for fundamental types.
  %typemap(ctype) const CPPTYPE& = CPPTYPE;
  // ...although we need to process input values as pointer
  %typemap(in, noblock=1) const CPPTYPE& = const CPPTYPE*;
  // ...and output values have to be dereferenced to turn into values
  %typemap(out) const CPPTYPE&
    "$result = *$1;"
  %typemap(imtype) const CPPTYPE& = CPPTYPE;
  %typemap(ftype)  const CPPTYPE& = CPPTYPE;
  %typemap(fin)    const CPPTYPE& = CPPTYPE;
  %typemap(fout)   const CPPTYPE& = CPPTYPE;

  // References to pointers
  FORT_COPY_TYPEMAPS(CPPTYPE*, CPPTYPE*&, const CPPTYPE* const&);
  FORT_COPY_TYPEMAPS(const CPPTYPE*, const CPPTYPE*&, const CPPTYPE* const&);

  // Const arrays are basically like const pointers
  FORT_COPY_TYPEMAPS(const CPPTYPE*, const CPPTYPE[], const CPPTYPE[ANY]);
  // ...except that fixed-sized arrays can be treated natively
  %typemap(ftype, out=FTYPE ", dimension(:), pointer", checkdim=1) const CPPTYPE[ANY]
    FTYPE ", dimension($1_dim0), target, intent(in)"
  %typemap(fout) const CPPTYPE[ANY] = CPPTYPE[ANY];

  FORT_COPY_TYPEMAPS(CPPTYPE*, CPPTYPE const [], CPPTYPE const [ANY]);
%enddef

/* -------------------------------------------------------------------------
 * \def FORT_FUND_TYPEMAP
 * \brief Add a typemap for a fundamental built-in type.
 *
 * The C++ and C types for standard argument wrapping are the same in this
 * case.
 *
 * For fundamental types we also define the "bindc" typemap, for mapping
 * member data of a "BIND(C)" struct from CTYPE to the equivalent Fortran type.
 * Usually this is the same as imtype, but since not all types are BIND(C)
 * compatible, this typemap is more restrictrive than "imtype".
 *
 * Finally, the fundamental type enables *declaring* C functions as pure
 * Fortran interface functions (using the '%bindc' feature) as opposed to
 * generating C wrapper code for them.
 */
%define FORT_FUND_TYPEMAP(CTYPE, FTYPE)
  FORT_SIMPLE_TYPEMAP(CTYPE, CTYPE, FTYPE)

  %typemap(bindc, in=FTYPE ", value") CTYPE
    FTYPE
  %typemap(bindc, in=FTYPE) CTYPE*
    "type(C_PTR)"
  %typemap(bindc) CTYPE[] = CTYPE*;
  %typemap(bindc, checkdim=1) CTYPE[ANY]
    FTYPE ", dimension($1_dim0)"

  %typemap(bindc, in=FTYPE", intent(in)") const CTYPE*
    "type(C_PTR)"
  %typemap(bindc, in=FTYPE", dimension(*), intent(in)") const CTYPE[]
    "type(C_PTR)"
  %typemap(bindc, in=FTYPE", dimension($1_dim0), intent(in)", checkdim=1) const CTYPE[ANY]
    "type(C_PTR)"

  %typemap(bindc, in=FTYPE ", dimension($1_dim1,*), intent(inout)", checkdim=1) CTYPE[][ANY]
    FTYPE ", dimension($1_dim1,*)"
  %typemap(bindc, in=FTYPE ", dimension($1_dim2,$1_dim1,*), intent(inout)", checkdim=1) CTYPE[][ANY][ANY]
    FTYPE ", dimension($1_dim2,$1_dim1,*)"

  %typemap(bindc, in=FTYPE ", dimension($1_dim1,*), intent(in", checkdim=1) const CTYPE[][ANY]
    FTYPE ", dimension($1_dim1,*)"
  %typemap(bindc, in=FTYPE ", dimension($1_dim2,$1_dim1,*), intent(in)", checkdim=1) const CTYPE[][ANY][ANY]
    FTYPE ", dimension($1_dim2,$1_dim1,*)"
%enddef

/* -------------------------------------------------------------------------
 * VOID TYPES
 * ------------------------------------------------------------------------- */

%typemap(ctype, null="")  void
  "void"
%typemap(out)    void
  ""
%typemap(imtype) void
  ""
%typemap(ftype)  void
  ""
%typemap(fin)    void
  ""
%typemap(fout)   void
  ""

%typemap(bindc) void
  ""

/* -------------------------------------------------------------------------
 * OPAQUE POINTERS
 * ------------------------------------------------------------------------- */

%typemap(ctype) void*
  "$1_ltype"
%typemap(in, noblock=1) void* {
  $1 = %reinterpret_cast($input, $1_ltype);
}
%typemap(out) void*
  "$result = $1;"
%typemap(imtype, in="type(C_PTR), value") void*
  "type(C_PTR)"
%typemap(ftype) void*
  "type(C_PTR)"
%typemap(fin)  void*
  "$1 = $input"
%typemap(fout)  void*
  "$result = $1"

// Void pointers are returned as opaque C pointers
FORT_COPY_TYPEMAPS(void*, const void*, void* const, void&, void[], void[ANY]);
// Handles are returned as opaque C pointers
FORT_COPY_TYPEMAPS(void*, SWIGTYPE**, SWIGTYPE* [], SWIGTYPE* [ANY])

// Use const-correct arguments/return values.
%typemap(in, noblock=1) const void* {
  $1 = %const_cast($input, $1_ltype);
}
FORT_COPY_TYPEMAPS(const void*,
                   const SWIGTYPE**, const SWIGTYPE* [], const SWIGTYPE* [ANY],
                   SWIGTYPE* const *, SWIGTYPE* const [], SWIGTYPE* const [ANY]);

// Generic pointers are treated as C pointers when binding
%typemap(bindc, in="type(C_PTR), value") SWIGTYPE*
  "type(C_PTR)"

/* -------------------------------------------------------------------------
 * FUNCTION POINTERS
 * ------------------------------------------------------------------------- */

%typemap(ctype)  SWIGTYPE (*)(ANY)
  %{$1_ltype%}
%typemap(in)     SWIGTYPE (*)(ANY)
  %{$1 = $input;%}
%typemap(out)    SWIGTYPE (*)(ANY)
  %{$result = $1;%}
%typemap(imtype, in="type(C_FUNPTR), value") SWIGTYPE (*)(ANY)
  "type(C_FUNPTR)"
%typemap(ftype, out="type(C_FUNPTR)")  SWIGTYPE (*)(ANY)
  "type(C_FUNPTR), intent(in), value"
%typemap(fin)    SWIGTYPE (*)(ANY)
  "$1 = $input"
%typemap(fout)   SWIGTYPE (*)(ANY)
  "$result = $1"

// Copy to immutable function pointers
FORT_COPY_TYPEMAPS(SWIGTYPE (*)(ANY), SWIGTYPE (*const)(ANY));

%typemap(bindc, in="type(C_FUNPTR), value") SWIGTYPE (*)(ANY)
  "type(C_FUNPTR)"

/* -------------------------------------------------------------------------
 * FUNDAMENTAL ISO C TYPES
 * ------------------------------------------------------------------------- */

FORT_FUND_TYPEMAP(bool       , "logical(C_BOOL)"     )
FORT_FUND_TYPEMAP(signed char, "integer(C_SIGNED_CHAR)")
FORT_FUND_TYPEMAP(short      , "integer(C_SHORT)"    )
FORT_FUND_TYPEMAP(int        , "integer(C_INT)"      )
FORT_FUND_TYPEMAP(long       , "integer(C_LONG)"     )
FORT_FUND_TYPEMAP(long long  , "integer(C_LONG_LONG)")
FORT_FUND_TYPEMAP(size_t     , "integer(C_SIZE_T)"   )
FORT_FUND_TYPEMAP(float      , "real(C_FLOAT)"       )
FORT_FUND_TYPEMAP(double     , "real(C_DOUBLE)"      )
FORT_FUND_TYPEMAP(char       , "character(C_CHAR)"   )

/* -------------------------------------------------------------------------
 * UNSIGNED INTEGER TYPES
 * ------------------------------------------------------------------------- */
/*
 * Since Fortran does not have unsigned types, we might want to validate that
 * the values being passed back and forth don't exceed the range of the signed
 * values (or ensure that values being passed to C++ aren't negative). However,
 * since some sentinel values are deliberately defined as e.g.
 * \code
 * foo = static_cast<unsigned int>(-1);
 * \endcode
 * we don't want to do this by default.
 *
 * Note that according to the Fortran standard "the C type unsigned char is
 * interoperable with the type integer with a kind type parameter of
 * C_SIGNED_CHAR".
 *
 * Note: ssize_t is defined in <sys/types.h> and isn't part of the standard.
 *
 * Because `FORT_FUND_TYPEMAP` creates all the derivative types and `%apply`
 * copies a single type, we explicitly remap these.
 */
FORT_FUND_TYPEMAP(unsigned char     , "integer(C_SIGNED_CHAR)");
FORT_FUND_TYPEMAP(unsigned short    , "integer(C_SHORT)");
FORT_FUND_TYPEMAP(unsigned int      , "integer(C_INT)");
FORT_FUND_TYPEMAP(unsigned long     , "integer(C_LONG)");
FORT_FUND_TYPEMAP(unsigned long long, "integer(C_LONG_LONG)");

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
%typemap(ctype, out="int") bool
  "const int*"
%typemap(in) bool
  "$1 = (*$input ? true : false);"
%typemap(out) bool
  "$result = ($1 ? 1 : 0);"
%typemap(imtype, in="integer(C_INT), intent(in)") bool
  "integer(C_INT)"
%typemap(ftype, out="logical") bool
  "logical, intent(in)"
%typemap(fin, fragment="SWIG_logical_to_int_f")  bool
  "$1 = SWIG_logical_to_int($input)"
%typemap(fout, fragment="SWIG_int_to_logical_f") bool
  "$result = SWIG_int_to_logical($1)"

// Treat const references like values
%apply bool { const bool& };
// ... except our 'in' typemap has to create a temporary
%typemap(in) const bool& (bool tempbool) {
  tempbool = (*$input ? true : false);
  $1 = &tempbool;
}

// Mutable references and arrays are treated like opaque pointers
%apply void* { bool[], bool[ANY],
  const bool*&, const bool[], const bool[ANY],
  bool const [], bool const [ANY],
  bool&, bool*&,
  const bool*, const bool* const };

/* -------------------------------------------------------------------------
 * TYPE CHECKING
 * ------------------------------------------------------------------------- */

// Type checking isn't used for Fortran but is required for unit tests
%typemap(typecheck, precedence=0) SWIGTYPE
  ""
%typemap(typecheck) char* = SWIGTYPE;

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
