/* File : example.i */
%{
#include "example.h"
%}

%module example

// Ignore return of types we don't understand (to prevent a warning)
%ignore ThinVec::data() const;

// Wrap the 'view' types in ThinVec as array pointers
%include <fortranarray.swg>

%define %thinvec_views(CPPTYPE)
%fortran_array_pointer(CPPTYPE, std::pair<CPPTYPE*, std::size_t>)
%typemap(in, noblock=1) std::pair<CPPTYPE*, std::size_t> {
  $1 = $1_type(static_cast<CPPTYPE*>($input->data), $input->size);
}
%typemap(out, noblock=1) std::pair<CPPTYPE*, std::size_t> {
  $result.data = $1.first;
  $result.size = $1.second;
}
%apply std::pair<CPPTYPE*, std::size_t> { std::pair<const CPPTYPE*, std::size_t> }
%enddef

/* -------------------------------------------------------------------------
 * Note: since we use %const_cast and %static_cast, which are SWIG-defined
 * macros, we must use {} rather than %{ %} for the typemap. To prevent those
 * enclosing braces from being inserted in the wrapper code, we add the
 * noblock=1 argument to the typemap.
 *
 * The typemap applies to input values with the name "INDICES", and it uses a
 * temporary variable (called tempvec) declared in the parentheses.
 * ------------------------------------------------------------------------- */

%typemap(in, noblock=1) const ThinVec<int>& INDICES (ThinVec<int> tempvec)
{
    // Original typemap: convert const ThinVec<int>* to thinvec reference
    $1 = %static_cast($input->cptr, $1_ltype);
    // Resize temporary vec
    tempvec.resize($1->size());
    // Copy input vector incremented by one
    $*1_ltype::const_iterator src = $1->begin();
    for ($*1_ltype::iterator dst = tempvec.begin();
         dst != tempvec.end();
         ++dst)
    {
        *dst = *src++ + 1;
    }
    // Make the input argument point to our temporary vector
    $1 = &tempvec;
}

// Load the thinvec class definition
%include "example.h"

// Set up typemaps for "views"
%thinvec_views(double)
%thinvec_views(int)

// Instantiate classes
%template(ThinVecDbl) ThinVec<double>;
%template(ThinVecInt) ThinVec<int>;

// Instantiate functions
%template(print_vec) print_vec<double>;
%template(print_vec) print_vec<int>;



