/* ------------------------------------------------------------
 *  Typemap specializations for Javascript
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */

/* These macros are necessary to provide an extra parameter
   to SWIG_AsVal_dec functions (JSContext *ctx).
   They must be defined before including `typemaps/fragments.swg`
*/
#define SWIG_FROM_DECL_ARGS SWIG_QUICKJS_FROM_DECL_ARGS
#define SWIG_FROM_CALL_ARGS SWIG_QUICKJS_FROM_CALL_ARGS
#define SWIG_AS_DECL_ARGS SWIG_QUICKJS_AS_DECL_ARGS
#define SWIG_AS_CALL_ARGS SWIG_QUICKJS_AS_CALL_ARGS

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

#define SWIG_Object                     JSValue
#define VOID_Object                     JS_UNDEFINED


#define SWIG_AppendOutput(result, obj) SWIG_QuickJS_AppendOutput(ctx, result, obj)
  
/* set constant */
#define SWIG_SetConstant(name, obj)
/* raise */
#define SWIG_Raise(obj, type, desc)  SWIG_QuickJS_raise(ctx, obj, type, desc)

%insert("runtime") %{
/* from javascripttypemaps.swg */  
#define SWIG_QUICKJS_FROM_DECL_ARGS(arg1)              (JSContext *ctx, arg1)
#define SWIG_QUICKJS_FROM_CALL_ARGS(arg1)              (ctx, arg1)
#define SWIG_QUICKJS_AS_DECL_ARGS(arg1, arg2)          (JSContext *ctx, arg1, arg2)
#define SWIG_QUICKJS_AS_CALL_ARGS(arg1, arg2)          (ctx, arg1, arg2)
%}

/* Include the unified typemap library */
%include <typemaps/swigtypemaps.swg>
