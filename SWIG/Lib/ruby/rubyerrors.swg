/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */


%insert("header") %{

SWIGINTERN VALUE
SWIG_Ruby_ErrorType(int SWIG_code) {
  switch (SWIG_code) {
  case SWIG_MemoryError:
    return rb_eNoMemError;
    break;
  case SWIG_IOError:
    return rb_eIOError;
    break;
  case SWIG_RuntimeError:
    return rb_eRuntimeError;
    break;
  case SWIG_IndexError:
    return rb_eIndexError;
    break;
  case SWIG_TypeError:
    return rb_eTypeError;
    break;
  case SWIG_DivisionByZero:
    return rb_eZeroDivError;
    break;
  case SWIG_OverflowError:
    return rb_eRangeError;
    break;
  case SWIG_SyntaxError:
    return rb_eSyntaxError;
    break;
  case SWIG_ValueError:
    return rb_eArgError;
    break;
  case SWIG_SystemError:
    return rb_eFatal;
    break;
  case SWIG_AttributeError:
    return rb_eRuntimeError;
    break;
  case SWIG_UnknownError:
    return rb_eRuntimeError;
    break;
  default:
    return rb_eRuntimeError;
    break;
  }
}


SWIGINTERN void
SWIG_Ruby_SetErrorMsg(VALUE type, const char *msg) {
  rb_raise(type, msg);
}

%}


