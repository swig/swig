/* File : stdvec.i */

%module stdvec

%{
#include <utility>
#include "stdvec.h"
%}

/* -------------------------------------------------------------------------
 * Instantiate the vector-double
 * ------------------------------------------------------------------------- */

%include <std_vector.i>

// Replace ULL type with fortran standard integer
// (needed BEFORE instantiating VecDbl)
%apply int { std::vector<double>::size_type };

%template(VecDbl) std::vector<double>;

/* -------------------------------------------------------------------------
 * Parse and instantiate the templated vector functions
 * ------------------------------------------------------------------------- */

// Make the "as_array_ptr" return an array pointer

%include "stdvec.h"

%template(as_array) as_array<double>;
%template(as_array_ptr) as_array_ptr<double>;
%template(print_vec) print_vec<double>;

/* -------------------------------------------------------------------------
 * Add a special copy-free "view" method that looks directly at a
 * Fortran-owned piece of data
 */

%include <typemaps.i>

%apply (SWIGTYPE *DATA, size_t SIZE) { (const double* data, std::size_t view) }

%template(print_view) print_view<double>;

/* -------------------------------------------------------------------------
 * Example of creating an allocatable array in Fortran by returning a vector by
 * value in C++
 */

%inline %{
std::vector<double> make_array() {
  static const int vals[] = {1,1,2,3,5,8};
  return std::vector<double>(vals, vals + 6);
}
%}

