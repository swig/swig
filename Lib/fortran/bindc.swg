/* -------------------------------------------------------------------------
 * bindc.swg
 * ------------------------------------------------------------------------- */

// Declare 'STRUCT' as a fundamental type, except instead of being `integer(C_INT)` it's `type($fclassname)`
FORT_FUND_TYPEMAP(STRUCT, type($fclassname))

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

%enddef
