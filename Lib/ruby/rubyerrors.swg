/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */


/* Define some additional error types */
#define SWIG_ObjectPreviouslyDeletedError  -100


/* Define custom exceptions for errors that do not map to existing Ruby
   exceptions.  Note this only works for C++ since a global cannot be
   initialized by a funtion in C.  For C, fallback to rb_eRuntimeError.*/

SWIGINTERN VALUE 
getNullReferenceError(void) {
  static int init = 0;
  static VALUE rb_eNullReferenceError ;
  if (!init) {
    init = 1;
    rb_eNullReferenceError = rb_define_class("NullReferenceError", rb_eRuntimeError);
  }
  return rb_eNullReferenceError;
} 

SWIGINTERN VALUE 
getObjectPreviouslyDeletedError(void) {
  static int init = 0;
  static VALUE rb_eObjectPreviouslyDeleted ;
  if (!init) {
    init = 1;
    rb_eObjectPreviouslyDeleted = rb_define_class("ObjectPreviouslyDeleted", rb_eRuntimeError);
  }
  return rb_eObjectPreviouslyDeleted;
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



