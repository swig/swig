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
 *
 */

/* Temporary definitions to allow parsing in the FORT_ARRAYPTR_TYPEMAP macro */
%define SWIGTMARGS__  (SWIGTYPE *DATA, size_t SIZE) %enddef

/* Transform the two-argument typemap into an array pointer */
FORT_ARRAYPTR_TYPEMAP($*1_ltype, SWIGTMARGS__)

/* Transform (SwigArrayWrapper *$input) -> (SWIGTYPE *DATA, size_t SIZE) */
%typemap(in, noblock=1) SWIGTMARGS__ {
$1 = %static_cast($input->data, $1_ltype);
$2 = $input->size;
}
/* Apply the typemaps to const versions as well */
%apply SWIGTMARGS__ { (const SWIGTYPE *DATA, size_t SIZE) };

#undef SWIGTMARGS__


