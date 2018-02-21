/* -------------------------------------------------------------------------
 * forruntime.swg
 * ------------------------------------------------------------------------- */

%include <typemaps/fragments.swg>

/* Insert SWIG error macros.
 *
 * Needs to be in a .swg file to allow downstream modules to use definitions
 * such as SWIG_RuntimeError
 */
%insert("runtime") "swigerrors.swg";

/* Default exception handler */
#ifdef __cplusplus
%fragment("<stdexcept>");
%insert(runtime) %{
#define SWIG_exception_impl(DECL, CODE, MSG, RETURNNULL) \
 { throw std::logic_error("In " DECL ": " MSG); RETURNNULL; }
%}
#else
%fragment("<stdio.h>");
%insert("runtime") %{
#include <assert.h>
#define SWIG_exception_impl(DECL, CODE, MSG, RETURNNULL) \
 { printf("In " DECL ": " MSG, NULL); assert(0); RETURNNULL; }
%}
#endif

/* Support for the `contract` feature. */
#define SWIG_contract_assert(EXPR, MSG) \
 if (!(EXPR)) { SWIG_exception_impl("$decl", SWIG_ValueError, MSG, return $null); } 

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
