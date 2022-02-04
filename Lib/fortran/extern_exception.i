/* -------------------------------------------------------------------------
 * extern_exception.i
 *
 * Only one SWIG+Fortran module in a library (regardless of whether the
 * modules are %imported or just linked together) can %include <exception.i>,
 * which instantiates an extern C linkage error variable and accessor function.
 *
 * %include this file near the top of a %module if extern-linkage exceptions
 * are required.
 *
 * This awkwardness is necessary because %imported SWIG files cannot inject
 * wrapper code.
 * ------------------------------------------------------------------------- */

/* Error if this file is being imported */
#ifdef SWIGIMPORTED
#error "extern_exception.i cannot be %imported: instead, %include <extern_exception.i> just below your %module declaration"
#endif

#define SWIG_FORTRAN_EXTERN_EXCEPTION
%import <exception.i>

/* Inject exception macros and extern function declarations */
%fragment("SWIG_exception_impl");

/* Inject SWIG error macro definitions */
%insert("runtime") "swigerrors.swg"
