/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */

%insert("header") %{


SWIGINTERN const char*
SWIG_Tcl_ErrorType(int code) {
  switch(code) {
  case SWIG_MemoryError:
    return "MemoryError";
  case SWIG_IOError:
    return "IOError";
  case SWIG_RuntimeError:
    return "RuntimeError";
  case SWIG_IndexError:
    return "IndexError";
  case SWIG_TypeError:
    return "TypeError";
  case SWIG_DivisionByZero:
    return "ZeroDivisionError";
  case SWIG_OverflowError:
    return "OverflowError";
  case SWIG_SyntaxError:
    return "SyntaxError";
  case SWIG_ValueError:
    return "ValueError";
  case SWIG_SystemError:
    return "SystemError";
  case SWIG_AttributeError:
    return "AttributeError";
  default:
    return "RuntimeError";
  }
}


SWIGINTERN void
SWIG_Tcl_SetErrorObj(Tcl_Interp *interp, const char *ctype, Tcl_Obj *obj)
{
  Tcl_ResetResult(interp);
  Tcl_SetObjResult(interp, obj);
  Tcl_SetErrorCode(interp, "SWIG", ctype, NULL);
}

SWIGINTERN void
SWIG_Tcl_SetErrorMsg(Tcl_Interp *interp, const char *ctype, const char *mesg)
{
  Tcl_ResetResult(interp);
  Tcl_SetErrorCode(interp, "SWIG", ctype, NULL);
  Tcl_AddErrorInfo(interp, mesg);
}

SWIGINTERNINLINE void
SWIG_Tcl_AddErrorMsg(Tcl_Interp *interp, const char* mesg)
{
  Tcl_AddErrorInfo(interp, mesg);
}



%}
