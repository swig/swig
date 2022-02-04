/* -------------------------------------------------------------------------
 * fortranruntime.swg
 * ------------------------------------------------------------------------- */

%include <typemaps/fragments.swg>

/* qualifier for exported *const* global data variables (enums) */
%insert("runtime") %{
#ifndef SWIGEXTERN
# ifdef __cplusplus
#   define SWIGEXTERN extern
# else
#   define SWIGEXTERN
# endif
#endif
%}

/* Default exception handler */
#ifdef __cplusplus
%fragment("<stdexcept>");
%insert(runtime) %{
#define SWIG_exception_impl(DECL, CODE, MSG, RETURNNULL) \
 { throw std::logic_error("In " DECL ": " MSG); }
%}
#else
%fragment("<stdio.h>");
%insert("runtime") %{
#include <assert.h>
#define SWIG_exception_impl(DECL, CODE, MSG, RETURNNULL) \
 { printf("In " DECL ": " MSG); assert(0); RETURNNULL; }
%}
#endif

%{
/* Support for the `contract` feature.
 *
 * Note that RETURNNULL is first because it's inserted via a 'Replaceall' in
 * the fortran.cxx file.
 */
#define SWIG_contract_assert(RETURNNULL, EXPR, MSG) \
 if (!(EXPR)) { SWIG_exception_impl("$decl", SWIG_ValueError, MSG, RETURNNULL); } 
%}
