/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */


%insert("header") %{

SWIGINTERN VALUE
SWIG_Ruby_ErrorType(int SWIG_code) {
  switch (SWIG_code) {
  case SWIG_MemoryError:
    return rb_eNoMemError;
  case SWIG_IOError:
    return rb_eIOError;
  case SWIG_RuntimeError:
    return rb_eRuntimeError;
  case SWIG_IndexError:
    return rb_eIndexError;
  case SWIG_TypeError:
    return rb_eTypeError;
  case SWIG_DivisionByZero:
    return rb_eZeroDivError;
  case SWIG_OverflowError:
    return rb_eRangeError;
  case SWIG_SyntaxError:
    return rb_eSyntaxError;
  case SWIG_ValueError:
    return rb_eArgError;
  case SWIG_SystemError:
    return rb_eFatal;
  case SWIG_AttributeError:
    return rb_eRuntimeError;
  case SWIG_UnknownError:
    return rb_eRuntimeError;
  default:
    return rb_eRuntimeError;
  }
}


SWIGINTERN void
SWIG_Ruby_SetErrorMsg(VALUE type, const char *msg) {
  rb_raise(type, msg);
}

%}


