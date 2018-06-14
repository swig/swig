/* -------------------------------------------------------------------------
 * typemaps.i
 * ------------------------------------------------------------------------- */

%include <forarray.swg>
%include <view.i>

/* -------------------------------------------------------------------------
 * Enable seamless translation of consecutive pointer/size arguments to Fortran
 * array views.
 *
 * To apply these to a function `void foo(double* x, int x_length);`:
 *
 * %apply (SWIGTYPE *DATA, size_t SIZE) { (double *x, int x_length) };
 */

/* Transform the two-argument typemap into an array pointer */
FORT_ARRAYPTR_TYPEMAP($*1_ltype, %arg((SWIGTYPE *DATA, size_t SIZE)))

/* Transform (SwigArrayWrapper *$input) -> (SWIGTYPE *DATA, size_t SIZE) */
%typemap(in, noblock=1) (SWIGTYPE *DATA, size_t SIZE) {
$1 = %static_cast($input->data, $1_ltype);
$2 = $input->size;
}
/* Apply the typemaps to const versions as well */
%apply (SWIGTYPE *DATA, size_t SIZE) { (const SWIGTYPE *DATA, size_t SIZE) };

