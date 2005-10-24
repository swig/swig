/* -----------------------------------------------------------------------------
 *  Typemap specializations
 * ----------------------------------------------------------------------------- */

/* directors are supported in Ruby */
#ifndef SWIG_DIRECTOR_TYPEMAPS
#define SWIG_DIRECTOR_TYPEMAPS
#endif

/* -----------------------------------------------------------------------------
 *  Basic definitions
 * ----------------------------------------------------------------------------- */
#define %convertptr_flags                $track
#define %newpointer_flags                $track
#define %newinstance_flags               $track

#define SWIG_Object                      VALUE
#define VOID_Object                      Qnil

#define SWIG_AppendOutput(result,obj)    SWIG_Ruby_AppendOutput(result, obj)
#define SWIG_SetConstant(name, obj)      rb_define_const($module, name, obj)
#define SWIG_Raise(obj, type, desc)      rb_exc_raise(rb_exc_new3(rb_eRuntimeError, rb_obj_as_string(obj)))
#define SWIG_DirOutFail(code, msg)       Swig::DirectorTypeMismatchException::raise(SWIG_ErrorType(code), msg)


/* -----------------------------------------------------------------------------
 *  All the typemaps
 * ----------------------------------------------------------------------------- */

%include <rubyprimtypes.swg>
%include <rubystrings.swg>
%include <typemaps/swigtypemaps.swg>


/* -----------------------------------------------------------------------------
 * Backward compatibility output helper 
 * ----------------------------------------------------------------------------- */
%fragment("output_helper","header") %{
#define output_helper SWIG_Ruby_AppendOutput
%}
