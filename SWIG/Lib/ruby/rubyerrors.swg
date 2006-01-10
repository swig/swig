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
#ifdef __cplusplus
static VALUE rb_eNullReferenceError = rb_define_class("NullReferenceError", rb_eRuntimeError);
static VALUE rb_eObjectPreviouslyDeleted = rb_define_class("ObjectPreviouslyDeleted", rb_eRuntimeError);
#endif

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
#ifdef __cplusplus
  case SWIG_NullReferenceError:
    type = rb_eNullReferenceError;
    break;
  case SWIG_ObjectPreviouslyDeletedError:
    type = rb_eObjectPreviouslyDeleted;
    break;
#endif
  case SWIG_UnknownError:
    type = rb_eRuntimeError;
    break;
  default:
    type = rb_eRuntimeError;
  }
  return type;
}

%}