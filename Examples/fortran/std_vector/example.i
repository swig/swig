/* File : example.i */

%module example

%{
#include <utility>
#include "example.h"
%}

/* -------------------------------------------------------------------------
 * Instantiate the vector-int
 * ------------------------------------------------------------------------- */

%include <std_vector.i>

// Replace ULL type with fortran standard integer
// (needed BEFORE instantiating VecInt)
%apply int { std::vector<int>::size_type };

%template(VecInt) std::vector<int>;

/* -------------------------------------------------------------------------
 * Parse and instantiate the templated vector functions
 * ------------------------------------------------------------------------- */

%include "example.h"

// Instead of returning an array pointer from "as_const_reference", treat it
// as a generic class (return a const reference to VecInt)
%apply const SWIGTYPE& { const std::vector<int>& as_const_reference<int>,
                         const std::vector<int>& inp};

%template(as_reference) as_reference<int>;
%template(as_const_reference) as_const_reference<int>;
%template(as_array) as_array<int>;
%template(as_array_ptr) as_array_ptr<int>;
%template(print_vec) print_vec<int>;

%inline %{
std::vector<int>* raw_ptr(std::vector<int>* inp)
{ return inp; }

const std::vector<int>* const_raw_ptr(const std::vector<int>* inp)
{ return inp; }

std::vector<int> from_value(std::vector<int> inp)
{ return inp; }

%}

/* -------------------------------------------------------------------------
 * Add a special copy-free "view" method that looks directly at a
 * Fortran-owned piece of data
 */

%include <typemaps.i>

%apply (SWIGTYPE *DATA, size_t SIZE) { (const int* data, std::size_t view) }

%template(print_view) print_view<int>;

/* -------------------------------------------------------------------------
 * Example of creating an allocatable array in Fortran by returning a vector by
 * value in C++
 */

%inline %{
std::vector<int> make_array() {
  static const int vals[] = {1,1,2,3,5,8};
  return std::vector<int>(vals, vals + 6);
}
%}

