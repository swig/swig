/* -------------------------------------------------------------------------
 * std_container.i
 *
 * Native typemaps for contiguous arrays: translate directly to and from Fortran
 * arrays. Returns an allocatable array copy of a std::vector reference.
 *
 * To avoid wrapping std::vector but still instantiate the typemaps that
 * allow native wrapping, use %template() std::vector<double>
 *
 * ------------------------------------------------------------------------- */

%include <fortranarray.swg>

/* -------------------------------------------------------------------------
 * \def %std_native_container
 *
 * Native typemaps for contiguous arrays: translate directly to and from Fortran
 * arrays.
 *
 * - The inputs are contiguous array views
 * - The outputs are allocatable arrays
 */
%define %std_native_container(ARRTYPE...)

/* ---- CONST REFERENCE: NATIVE ARRAY ---- */

// Define ctype, imtype, ftype to create Fortran array pointers; we want to
// reuse this type definition for the "view" accessor of a vector
%fortran_array_pointer(%arg(ARRTYPE::value_type), ARRTYPE& POINTER)

// "Pointer"-like treatment for the vector (used by the `view()` std::vector accessor and inherited by `const ARRTYPE&`)
%typemap(out, noblock=1) ARRTYPE& POINTER {
  $result.data = ($1->empty() ? NULL : &(*$1->begin()));
  $result.size = $1->size();
}

// Reuse the ctype/imtype typemaps for getting array by const reference
%apply ARRTYPE& POINTER { const ARRTYPE& };

// C native input translation typemaps: copy to a temporary vector
%typemap(in, noblock=1) const ARRTYPE& (ARRTYPE temparr, ARRTYPE::value_type* tempbegin) {
  tempbegin = static_cast<ARRTYPE::value_type*>($input->data);
  temparr.assign(tempbegin, tempbegin + $input->size);
  $1 = &temparr;
}

/* ---- VALUE: NATIVE ARRAY ---- */

%apply const ARRTYPE& { ARRTYPE };

// C native input translation typemaps: copy to a temporary vector
%typemap(in, noblock=1) ARRTYPE (ARRTYPE::value_type* tempbegin) {
  tempbegin = static_cast<ARRTYPE::value_type*>($input->data);
  $1.assign(tempbegin, tempbegin + $input->size);
}

// Copy the array to a temporary buffer, because its scope has to persist past the end
// of the SWIG C wrapper function
%typemap(out, fragment="<stdlib.h>", fragment="<string.h>", noblock=1) ARRTYPE {
  $result.size = $1.size();
  if ($result.size > 0) {
    $result.data = malloc($result.size * sizeof(ARRTYPE::value_type));
    memcpy($result.data, &($1[0]), $result.size * sizeof(ARRTYPE::value_type));
  } else {
    $result.data = NULL;
  }
}

// Declare Fortran type: single-dimension input, allocatable output
%typemap(ftype, in={$typemap(imtype, ARRTYPE::value_type), dimension(:), target, intent(in)}, noblock=1)
    ARRTYPE {
  $typemap(imtype, ARRTYPE::value_type), dimension(:), allocatable
}

// Fortran proxy translation code: convert from imtype $1 to ftype $result
%typemap(foutdecl, noblock=1, match="fout") ARRTYPE {
  $typemap(imtype, ARRTYPE::value_type), pointer :: $1_view(:)
}

// Fortran proxy translation code: copy array contents and free the malloc'd copy
%typemap(fout, fragment="SWIG_free_f", noblock=1) ARRTYPE {
  call c_f_pointer($1%data, $1_view, [$1%size])
  allocate($result(size($1_view)))
  $result = $1_view
  call SWIG_free($1%data)
}

/* ---- MUTABLE REFERENCE: CLASS OBJECT ---- */

// Since this is the default behavior it's not necessary to do this 'apply'
// %apply SWIGTYPE& { ARRTYPE& };

%enddef




