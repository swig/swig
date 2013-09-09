/* ------------------------------------------------------------
 *  Typemap specializations for Javascript
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */

/* These macros are necessary to provide an extra parameter
   to SWIG_AsVal_dec functions (JSContextRef context).
*/
#define SWIG_FROM_DECL_ARGS SWIG_JSC_FROM_DECL_ARGS
#define SWIG_FROM_CALL_ARGS SWIG_JSC_FROM_CALL_ARGS
#define SWIG_AS_DECL_ARGS SWIG_JSC_AS_DECL_ARGS
#define SWIG_AS_CALL_ARGS SWIG_JSC_AS_CALL_ARGS

/* Include fundamental fragemt definitions */
%include <typemaps/fragments.swg>

/* Look for user fragments file. */
%include <javascriptfragments.swg>

/* Javascript fragments for fundamental types */
%include <javascriptprimtypes.swg>

/* Javascript fragments for char* strings */
%include <javascriptstrings.swg>

/* ------------------------------------------------------------
 *  Unified typemap section
 * ------------------------------------------------------------ */

#define SWIG_Object                     JSValueRef
#define VOID_Object                     JSValueMakeUndefined(context)

/* append output */
#define SWIG_AppendOutput(result, obj)

/* set constant */
#define SWIG_SetConstant(name, obj)

/* raise */
#define SWIG_Raise(obj, type, desc)  SWIG_Javascript_Raise(context, exception, type)

/* Include the unified typemap library */
%include <typemaps/swigtypemaps.swg>
