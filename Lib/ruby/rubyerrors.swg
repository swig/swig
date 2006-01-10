/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */

%insert("runtime") "swigerrors.swg"

/* Define some additional error types */
%insert("runtime") %{
#define SWIG_ObjectPreviouslyDeletedError  -100
%}

%insert("header") %{

/* Define custom exceptions for errors that do not map to existing Ruby
   exceptions.  Note this only works for C++ since a global cannot be
   initialized by a funtion in C.  For C, fallback to rb_eRuntimeError.*/

VALUE getNullReferenceError() {
  static int init = 0;
  static VALUE rb_eNullReferenceError ;
  if (!init) {
    init = 1;
    rb_eNullReferenceError = rb_define_class("NullReferenceError", rb_eRuntimeError);
  }
  return rb_eNullReferenceError;
} 

VALUE getObjectPreviouslyDeletedError() {
  static int init = 0;
  static VALUE rb_eObjectPreviouslyDeleted ;
  if (!init) {
    init = 1;
    rb_eObjectPreviouslyDeleted = rb_define_class("ObjectPreviouslyDeleted", rb_eRuntimeError);
  }
  return rb_eObjectPreviouslyDeleted;
} 

VALUE getExceptionClass() {
  static int init = 0;
  static VALUE rubyExceptionClass ;
  if (!init) {
    init = 1;
    rubyExceptionClass = rb_const_get(_mSWIG, rb_intern("Exception"));
  }
  return rubyExceptionClass;
} 

SWIGINTERN VALUE
SWIG_Ruby_ErrorType(int SWIG_code) {
  VALUE type;
  switch (SWIG_code) {
  case SWIG_MemoryError:
    type = rb_eNoMemError;
    break;
  case SWIG_IOError:
    type = rb_eIOError;
    break;
  case SWIG_RuntimeError:
    type = rb_eRuntimeError;
    break;
  case SWIG_IndexError:
    type = rb_eIndexError;
    break;
  case SWIG_TypeError:
    type = rb_eTypeError;
    break;
  case SWIG_DivisionByZero:
    type = rb_eZeroDivError;
    break;
  case SWIG_OverflowError:
    type = rb_eRangeError;
    break;
  case SWIG_SyntaxError:
    type = rb_eSyntaxError;
    break;
  case SWIG_ValueError:
    type = rb_eArgError;
    break;
  case SWIG_SystemError:
    type = rb_eFatal;
    break;
  case SWIG_AttributeError:
    type = rb_eRuntimeError;
    break;
  case SWIG_NullReferenceError:
    type = getNullReferenceError();
    break;
  case SWIG_ObjectPreviouslyDeletedError:
    type = getObjectPreviouslyDeletedError();
    break;
  case SWIG_UnknownError:
    type = rb_eRuntimeError;
    break;
  default:
    type = rb_eRuntimeError;
  }
  return type;
}


/* This code checks to see if the Ruby object being raised as part
   of an exception inherits from the Ruby class Exception.  If so,
   the object is simply returned.  If not, then a new Ruby exception
   object is created and that will be returned to Ruby.*/
SWIGINTERN VALUE
SWIG_Ruby_ExceptionType(swig_type_info *desc, VALUE obj) {
  VALUE exceptionClass = getExceptionClass();
  if (rb_obj_is_kind_of(obj, exceptionClass)) {
    return obj;
  }  else {
    return rb_exc_new3(rb_eRuntimeError, rb_obj_as_string(obj));
  }
}

%}