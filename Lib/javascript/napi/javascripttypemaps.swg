/* ------------------------------------------------------------
 *  Typemap specializations for Javascript
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */

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
#define SWIG_AppendOutput(result, obj) SWIGNAPI_AppendOutput(result, obj)

/* set constant */
#define SWIG_SetConstant(name, obj)

/* raise */
#define SWIG_Raise(obj, type, desc)  SWIG_NAPI_Raise(obj, type)

/* Include the unified typemap library */
%include <typemaps/swigtypemaps.swg>
