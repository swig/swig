/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */

%insert("runtime") "swigerrors.swg"

%insert("header") %{

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
  case SWIG_UnknownError:
    type = rb_eRuntimeError;
    break;
  default:
    type = rb_eRuntimeError;
  }
  return type;
}

%}


