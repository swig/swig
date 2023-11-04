/* -------------------------------------------------------------------------
 * typemaps.i
 * ------------------------------------------------------------------------- */

%include <fortranarray.swg>

/* -------------------------------------------------------------------------
 * Enable seamless translation of consecutive pointer/size arguments to Fortran
 * array views.
 *
 * To apply these to a function `void foo(double* x, int x_length);`:
 *
 * %apply (SWIGTYPE *DATA, size_t SIZE) { (double *x, int x_length) };
 */

/* Transform the two-argument typemap into an array pointer */
%fortran_array_pointer($*1_ltype, %arg((SWIGTYPE *DATA, size_t SIZE)))

/* Transform (SwigArrayWrapper *$input) -> (SWIGTYPE *DATA, size_t SIZE) */
%typemap(in, noblock=1) (SWIGTYPE *DATA, size_t SIZE) {
$1 = ($1_ltype)$input->data;
$2 = $input->size;
}

/* Apply the typemaps to const versions as well */
%apply (SWIGTYPE *DATA, size_t SIZE) { (const SWIGTYPE *DATA, size_t SIZE) };

/* Add 'intent(in)' for const arrays */
%typemap(ftype, in="$typemap(imtype, $*1_ltype), dimension(:), intent(in), target", noblock=1) (const SWIGTYPE *DATA, size_t SIZE) {
  $typemap(imtype, $*1_ltype), dimension(:), pointer
}

/* -------------------------------------------------------------------------
 * Interact natively with Fortran fixed-size arrays.
 *
 * To apply these to a function `void foo(const int x[4]);`:
 *
 * %apply SWIGTYPE ARRAY[ANY] {const int x[4] };
 */

%apply FORTRAN_INTRINSIC_TYPE& { SWIGTYPE ARRAY[ANY], SWIGTYPE ARRAY[ANY][ANY], SWIGTYPE ARRAY[ANY][ANY][ANY] }

%typemap(ftype, in="$typemap(ftype, $1_basetype), dimension($1_dim0), target", checkdim=1) SWIGTYPE ARRAY[ANY]
 "$typemap(ftype, $1_basetype), dimension($1_dim0)"
%typemap(ftype, in="$typemap(ftype, $1_basetype), dimension($1_dim1,$1_dim0), target", checkdim=1) SWIGTYPE ARRAY[ANY][ANY]
 "$typemap(ftype, $1_basetype), dimension($1_dim1,$1_dim0)"
%typemap(ftype, in="$typemap(ftype, $1_basetype), dimension($1_dim2,$1_dim1,$1_dim0), target", checkdim=1) SWIGTYPE ARRAY[ANY][ANY][ANY]
 "$typemap(ftype, $1_basetype), dimension($1_dim2,$1_dim1,$1_dim0)"

%typemap(fout, temp="$typemap(ftype, $1_basetype), dimension(:), pointer", checkdim=1, noblock=1) SWIGTYPE ARRAY[ANY]
{call c_f_pointer($1, $1_temp, [$1_dim0])
$result = $1_temp}
%typemap(fout, temp="$typemap(ftype, $1_basetype), dimension(:,:), pointer", checkdim=1, noblock=1) SWIGTYPE ARRAY[ANY][ANY]
{call c_f_pointer($1, $1_temp, [$1_dim1,$1_dim0])
$result = $1_temp}
%typemap(fout, temp="$typemap(ftype, $1_basetype), dimension(:,:,:), pointer", checkdim=1, noblock=1) SWIGTYPE ARRAY[ANY][ANY][ANY]
{call c_f_pointer($1, $1_temp, [$1_dim2,$1_dim1,$1_dim0])
$result = $1_temp}

%typemap(fin) SWIGTYPE ARRAY[ANY], SWIGTYPE ARRAY[ANY][ANY], SWIGTYPE ARRAY[ANY][ANY][ANY]
  "$1 = c_loc($input)"

// Generic array types with unknown dimensions for C binding
%typemap(bindc, in="$typemap(bindc, $1_basetype), dimension($1_dim0), target", checkdim=1) SWIGTYPE ARRAY[ANY]
 "$typemap(bindc, $1_basetype), dimension($1_dim0)"
%typemap(bindc, in="$typemap(bindc, $1_basetype), dimension($1_dim1,$1_dim0), target", checkdim=1) SWIGTYPE ARRAY[ANY][ANY]
 "$typemap(bindc, $1_basetype), dimension($1_dim1,$1_dim0)"
%typemap(bindc, in="$typemap(bindc, $1_basetype), dimension($1_dim2,$1_dim1,$1_dim0), target", checkdim=1) SWIGTYPE ARRAY[ANY][ANY][ANY]
 "$typemap(bindc, $1_basetype), dimension($1_dim2,$1_dim1,$1_dim0)"


/* -------------------------------------------------------------------------
 * Interact natively with Fortran deferred-size arrays.
 *
 * To apply these to a function `void foo(const int* x);`:
 *
 * %apply SWIGTYPE ARRAY[] {const int* x };
 */

%apply SWIGTYPE ARRAY[ANY] { SWIGTYPE ARRAY[] };
%apply SWIGTYPE ARRAY[ANY][ANY] { SWIGTYPE ARRAY[][ANY] };
%apply SWIGTYPE ARRAY[ANY][ANY][ANY] { SWIGTYPE ARRAY[][ANY][ANY] };

