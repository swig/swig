/* ------------------------------------------------------------
 *  Typemap specializations for Ruby
 * ------------------------------------------------------------ */
/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */

/* Include fundamental fragemt definitions */
%include <typemaps/fragments.swg>

/* Look for user fragments file. */
%include <rubyfragments.swg>

/* Ruby fragments for primitive types */
%include <rubyprimtypes.swg>

/* Ruby fragments for char* strings */
%include <rubystrings.swg>

/* Backward compatibility output helper */
%fragment("output_helper","header") %{
#define output_helper SWIG_Ruby_AppendOutput
%}

/* ------------------------------------------------------------
 *  Unified typemap section
 * ------------------------------------------------------------ */

/* Directors are supported in Ruby */
#ifndef SWIG_DIRECTOR_TYPEMAPS
#define SWIG_DIRECTOR_TYPEMAPS
#endif


/* Ruby types */
#define SWIG_Object                      VALUE
#define VOID_Object                      Qnil

/* Simple overload of the output/constant/exception handling */
#define SWIG_AppendOutput(result,obj)    SWIG_Ruby_AppendOutput(result, obj)
#define SWIG_SetConstant(name, obj)      rb_define_const($module, name, obj)

/* raise */
%define SWIG_Raise(obj, type, desc)
	VALUE exc = SWIG_Ruby_ExceptionType(desc, obj);
	rb_exc_raise(exc)%enddef

/* Include the unified typemap library */
%include <typemaps/swigtypemaps.swg>


