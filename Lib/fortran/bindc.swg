/* -------------------------------------------------------------------------
 * bindc.swg
 * ------------------------------------------------------------------------- */

FORT_FUND_TYPEMAP(STRUCT, "type($fclassname)")

// Mostly like fundamental types, BUT:
//
// ctype is defined when %type_bindc is called
// imtype is the actual bound struct
// bindc needs 'import'
%typemap(imtype, import="$fclassname") STRUCT
  "type($fclassname)"
%typemap(bindc, in="type($fclassname), value", import="$fclassname") STRUCT
  "type($fclassname)"
%typemap(ftype) STRUCT
  "type($fclassname)"

%typemap(bindc, in="type($fclassname), intent(inout)", import="$fclassname") STRUCT*
  "type(C_PTR)"
%typemap(bindc, in="type($fclassname), intent(in)", import="$fclassname") const STRUCT*
  "type(C_PTR)"

/*!
 * \def %fortranbindc_type
 * \brief Wrap a struct as BIND(C).
 *
 * The typemap lookup is as follows for a struct Foo being wrapped, using the example of ctype.
 *  1. `Foo *` is %applied from `STRUCT *` via `FORT_APPLY_TYPEMAPS` below.
 *  2. `STRUCT *` is %applied from `FUNDTYPE *` via `FORT_FUND_TYPEMAP` above.
 *  3. `FUNDTYPE *` has the typemap of `"$typemap(ctype, $*1_ltype)*"`, which evaulates
 *     to `$typemap(ctype, Foo)*`.
 *  4. `Foo` (value) is %applied from `STRUCT` in the explicit `%apply` below.
 *  5. The `STRUCT` value ctype is copied from the `FUNDTYPE` type via `FORT_FUND_TYPEMAP`.
 * ------------------------------------------------------------------------- */
%define %fortranbindc_type(CLS)
  // Mark the class as being C-bound
  %fortranbindc CLS;

  // Create fragment for initializing an empty struct
  %fragment("SWIG_null_struct"{CLS}, "header", fragment="<string.h>", noblock=1) {
  CLS SWIG_null_struct_ ## CLS() {
    CLS result;
    memset(&result, 0, sizeof(CLS));
    return result;
  }
  }

  // Apply basic typemaps
  %apply STRUCT { CLS };
  FORT_APPLY_TYPEMAPS(STRUCT, CLS)

  // Set up C type
  %typemap(ctype, in={const CLS*}, null={SWIG_null_struct_ ## CLS()}, fragment="SWIG_null_struct"{CLS}, noblock=1) CLS {
    CLS
  }
  %typemap(ctype, noblock=1) CLS *const & {
    const CLS*
  }
  %apply CLS *const & { const CLS *const & };

%enddef
