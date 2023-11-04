/* -------------------------------------------------------------------------
 * std_common.i
 *
 * This empty file is referenced by the size_t unit test; it's possible other
 * applications might unwittingly reference this file as well.
 * ------------------------------------------------------------------------- */

// Typemaps for converting Fortran indexing to and from C indexing.
%typemap(in) int FORTRAN_INDEX "$1 = *$input - 1;"
%typemap(out) int FORTRAN_INDEX "$result = $1 + 1;"


// Typemaps for converting Fortran native-length integers to and from other ints
%typemap(ftype, in="integer, intent(in)") int FORTRAN_INT "integer"
%typemap(fin) int FORTRAN_INT "$1 = int($input, C_INT)"
%typemap(fout) int FORTRAN_INT "$result = int($1)"

// Runtime check for range validity
%fragment("SWIG_check_range", "runtime") %{
#define SWIG_check_range(INDEX, SIZE, FUNCNAME, RETURNNULL) \
  if (!(INDEX < SIZE)) { \
    SWIG_exception_impl(FUNCNAME, SWIG_IndexError, \
                        "index out of range", RETURNNULL); \
  }
%}

