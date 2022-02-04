/* -------------------------------------------------------------------------
 * bindc.swg
 * ------------------------------------------------------------------------- */

// Declare a generic `FORTRAN_STRUCT_TYPE` as a native type.
// Rather than being an intrinsic type `integer(C_INT)` it's a derived type `type($fortranclassname)`
%fortran_intrinsic(FORTRAN_STRUCT_TYPE, type, $fortranclassname)
// Avoid 'C99 forbids casting nonscalar type 'XY' to the same type'
%typemap(in) FORTRAN_STRUCT_TYPE "$1 = *$input;"
%typemap(out) FORTRAN_STRUCT_TYPE "$result = $1;"

/*!
 * \def %fortran_struct
 * \brief Wrap a struct as BIND(C).
 *
 * The typemap lookup is as follows for a struct Foo being wrapped, using the example of ctype.
 *  1. `Foo *` is %applied from `FORTRAN_STRUCT_TYPE *` via `%fortran_apply_typemaps` below.
 *  2. `FORTRAN_STRUCT_TYPE *` is %applied from `FORTRAN_INTRINSIC_TYPE *` via `%fortran_intrinsic` above.
 *  3. `FORTRAN_INTRINSIC_TYPE *` has the typemap of `"$typemap(ctype, $*1_ltype)*"`, which evaulates
 *     to `$typemap(ctype, Foo)*`.
 *  4. `Foo` (value) is %applied from `FORTRAN_STRUCT_TYPE` in the explicit `%apply` below.
 *  5. The `FORTRAN_STRUCT_TYPE` value ctype is copied from the `FORTRAN_INTRINSIC_TYPE` type via `%fortran_intrinsic`.
 * ------------------------------------------------------------------------- */
%define %fortran_struct(CLS)
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
  %apply FORTRAN_STRUCT_TYPE { CLS };
  %fortran_apply_typemaps(FORTRAN_STRUCT_TYPE, CLS)

  // Override 'SWIGTYPE' behavior for pointers to make it behave like references. Otherwise it behaves like SWIGTYPE*, which is wrapped as a class; as
  // opposed to int*, which is wrapped as an opaque type.
  %apply FORTRAN_INTRINSIC_TYPE& { CLS*, CLS[], CLS[ANY] };

  // Wrap pointers natively
  %typemap(bindc) CLS* = FORTRAN_INTRINSIC_TYPE*;
  %typemap(bindc) const CLS* = const FORTRAN_INTRINSIC_TYPE*;

  // Set up C type
  %typemap(ctype, in="const " #CLS "*", null="SWIG_null_struct_" #CLS "()", fragment="SWIG_null_struct"{CLS}, noblock=1) CLS {
    CLS
  }

%enddef
