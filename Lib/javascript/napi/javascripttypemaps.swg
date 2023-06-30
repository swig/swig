/* ------------------------------------------------------------
 *  Typemap specializations for Javascript
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */

/* These macros are necessary to provide an extra parameter
   to SWIG_AsVal_dec functions (Napi::Env environment).
   They must be defined before including `typemaps/fragments.swg`
*/
#define SWIG_FROM_DECL_ARGS SWIG_NAPI_FROM_DECL_ARGS
#define SWIG_FROM_CALL_ARGS SWIG_NAPI_FROM_CALL_ARGS

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

/* Javascript types */

#define SWIG_Object                     Napi::Value
#define VOID_Object                     env.Undefined()

/* Overload of the output/constant/exception/dirout handling */

/* append output */
#define SWIG_AppendOutput(result, obj)  SWIG_NAPI_AppendOutput(env, result, obj)

/* set constant */
#define SWIG_SetConstant(name, obj)

/* raise */
#define SWIG_Raise(...)                 SWIG_NAPI_Raise(env, __VA_ARGS__)

%insert("runtime") %{
#define SWIG_NAPI_FROM_DECL_ARGS(arg1)              (Napi::Env env, arg1)
#define SWIG_NAPI_FROM_CALL_ARGS(arg1)              (env, arg1)
%}


/* Include the unified typemap library */
%include <typemaps/swigtypemaps.swg>
