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
 * FRAGMENTS
 * ------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------
 * \def %std_native_container
 *
 * Native typemaps for contiguous arrays: translate directly to and from Fortran
 * arrays.
 *
 * - The inputs are contiguous array views
 * - The outputs are allocatable arrays
 */
%define %std_vector_impl(CTYPE, CPPTYPE...)

// Const reference
%fortran_array_pointer(CTYPE, const CPPTYPE&)

%typemap(out, noblock=1) const CPPTYPE& {
  $result.data = ($1->empty() ? NULL : &(*$1->begin()));
  $result.size = $1->size();
}

%typemap(in, noblock=1) const CPPTYPE& (CPPTYPE temparr, CTYPE* tempbegin) {
  tempbegin = static_cast<CTYPE*>($input->data);
  temparr.assign(tempbegin, tempbegin + $input->size);
  $1 = &temparr;
}

/* ---- VALUE: NATIVE ARRAY ---- */

%apply const CPPTYPE& { CPPTYPE };

// C native input translation typemaps: copy to a temporary vector
%typemap(in, noblock=1) CPPTYPE (CTYPE* tempbegin) {
  tempbegin = static_cast<CTYPE*>($input->data);
  $1.assign(tempbegin, tempbegin + $input->size);
}

// Copy the array to a temporary buffer, because its scope has to persist past the end
// of the SWIG C wrapper function
%typemap(out, fragment="<stdlib.h>", fragment="<string.h>", noblock=1) CPPTYPE {
  $result.size = $1.size();
  if ($result.size > 0) {
    $result.data = malloc($result.size * sizeof(CTYPE));
    memcpy($result.data, &($1[0]), $result.size * sizeof(CTYPE));
  } else {
    $result.data = NULL;
  }
}

// Declare Fortran type: single-dimension input, allocatable output
%typemap(ftype, in={$typemap(imtype, CTYPE), dimension(:), target, intent(in)}, noblock=1)
    CPPTYPE {
  $typemap(imtype, CTYPE), dimension(:), allocatable
}

// Fortran proxy translation code: copy array contents and free the malloc'd copy
%typemap(fout, fragment="SWIG_free_f", noblock=1,
         temp={$typemap(imtype, CTYPE), dimension(:), pointer}
         ) CPPTYPE {
  if ($1%size > 0) then
    call c_f_pointer($1%data, $1_temp, [$1%size])
    allocate($result(size($1_temp)))
    $result = $1_temp
    call SWIG_free($1%data)
  else
    allocate($result(0))
  endif
}

%enddef




