/* File : stdvec.i */

%module stdvec

%{
#include <utility>
#include "stdvec.h"
%}

/* -------------------------------------------------------------------------
 * EXTEND VECTOR TO HAVE VIEWS
 * ------------------------------------------------------------------------- */

%include <typemaps.i>

%define ADD_VIEW(TYPE)

// Instantiate view typemap
%fortran_view(double)

// Replace ULL type with fortran standard integer
%apply int { std::vector<TYPE>::size_type };

// Extend vector
%extend std::vector<TYPE> {
  void fill(std::pair<const TYPE*, std::size_t> view) {
    $self->assign(view.first, view.first + view.second);
  }

  std::pair<TYPE*, std::size_t> view() {
    if ($self->empty())
      return {nullptr, 0};
    return {$self->data(), $self->size()};
  }
} // end extend

%enddef

/* -------------------------------------------------------------------------
 * Instantiate the vector-double
 * ------------------------------------------------------------------------- */

%include <std_vector.i>

ADD_VIEW(double)

%template(VecDbl) std::vector<double>;

/* -------------------------------------------------------------------------
 * ARRAY VIEW EXAMPLE
 * ------------------------------------------------------------------------- */
%include <forarray.swg>

// Convert a reference-to-vector return value into a array view.
FORT_ARRAYPTR_TYPEMAP(double, std::vector<double>& NATIVE)
%typemap(out) std::vector<double>& NATIVE %{
  $result.data = $1->empty() ? NULL : $1->data();
  $result.size = $1->size();
%}

%apply std::vector<double>& NATIVE { std::vector<double>& as_array_ptr };

/* -------------------------------------------------------------------------
 * Parse and instantiate the templated functions
 * ------------------------------------------------------------------------- */

// Make the single "get_vec_ref" function return a native allocated fortran array
// (This is enabled by the instantiation of std::vector.).
// Note that the signature as written only causes the *out* typemaps to apply --
// the input typemaps still correspond to the std::vector class.
%apply const std::vector<double>& NATIVE { const std::vector<double>& get_vec<double> };

%include "stdvec.h"

%template(make_viewdbl) make_view<double>;
%template(make_const_viewdbl) make_const_view<double>;
%template(print_viewdbl) print_view<double>;
%template(get_vecdbl) get_vec<double>;

/* -------------------------------------------------------------------------
 * Example of creating an allocatable array in Fortran by returning a vector by
 * value in C++
 */

%apply std::vector<double> NATIVE { std::vector<double> make_array };

%inline %{
std::vector<double> make_array() { return {1,1,2,3,5}; }
%}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
