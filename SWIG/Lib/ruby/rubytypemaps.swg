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

%define_swig_object(VALUE)

#define SWIG_VoidObject()               Qnil
#define SWIG_SetResultObj(obj)          $result = obj
#define SWIG_AppendResultObj(obj)       $result = SWIG_Ruby_AppendResult($result, obj)
#define SWIG_SetConstantObj(name, obj)  rb_define_const($module, name, obj)
#define SWIG_Raise(obj, type, desc)     rb_exc_raise(rb_exc_new3(rb_eRuntimeError, rb_obj_as_string(obj)))
#define SWIG_DirOutFail(code, msg)      Swig::DirectorTypeMismatchException::raise(SWIG_ErrorType(code), msg)


/* -----------------------------------------------------------------------------
 *  All the typemaps
 * ----------------------------------------------------------------------------- */

%include <typemaps/exception.swg>
%include <typemaps/swigtype.swg>
%include <typemaps/void.swg>
%include <typemaps/valtypes.swg>
%include <typemaps/ptrtypes.swg>
%include <typemaps/swigobject.swg>
%include <typemaps/inoutlist.swg>
%include <rubyprimtypes.swg>
%include <rubystrings.swg>
%include <typemaps/misctypes.swg>
%include <typemaps/enumint.swg>


/* -----------------------------------------------------------------------------
 * Backward compatibility output helper 
 * ----------------------------------------------------------------------------- */
%fragment("output_helper","header") %{
#define output_helper SWIG_Ruby_AppendResult
%}
