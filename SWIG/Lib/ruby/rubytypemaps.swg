/* -----------------------------------------------------------------------------
 *  Typemap specializations
 * ----------------------------------------------------------------------------- */

/* directors are supported in Python */
#ifndef SWIG_DIRECTOR_TYPEMAPS
#define SWIG_DIRECTOR_TYPEMAPS
#endif

/* -----------------------------------------------------------------------------
 *  Basic definitions
 * ----------------------------------------------------------------------------- */

%define_swig_object(VALUE)

#define SWIG_SetResultObj(obj)          $result = obj
#define SWIG_AppendResultObj(obj)       $result = SWIG_Ruby_AppendResult($result, obj)
#define SWIG_SetConstantObj(name, obj)  rb_define_const($module, name, obj);
#define SWIG_NoneObject()               Qnil

/* error manipulation */
#define SWIG_ErrorType(code)            SWIG_Ruby_ErrorType(code)
#define SWIG_SetErrorObj(code, obj)     SWIG_Ruby_SetErrorMsg(SWIG_ErrorType(code),obj)
#define SWIG_SetErrorMsg(code, msg)     SWIG_Ruby_SetErrorMsg(SWIG_ErrorType(code),msg)
#define SWIG_ExceptionObj(d, type, obj) rb_exc_raise(rb_exc_new3(rb_eRuntimeError, rb_obj_as_string(obj)))
#define SWIG_DirOutFail(code, msg)      Swig::DirectorTypeMismatchException::raise(SWIG_ErrorType(code), msg)


/* -----------------------------------------------------------------------------
 *  All the typemaps
 * ----------------------------------------------------------------------------- */

%include "rubyfragments.swg"

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

