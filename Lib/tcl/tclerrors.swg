/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */

%insert("header") %{


SWIGINTERN const char*
SWIG_Tcl_ErrorType(int code) {
  switch(code) {
  case SWIG_MemoryError:
    return "MemoryError";
    break;
  case SWIG_IOError:
    return "IOError";
    break;
  case SWIG_RuntimeError:
    return "RuntimeError";
    break;
  case SWIG_IndexError:
    return "IndexError";
    break;
  case SWIG_TypeError:
    return "TypeError";
    break;
  case SWIG_DivisionByZero:
    return "ZeroDivisionError";
    break;
  case SWIG_OverflowError:
    return "OverflowError";
    break;
  case SWIG_SyntaxError:
    return "SyntaxError";
    break;
  case SWIG_ValueError:
    return "ValueError";
    break;
  case SWIG_SystemError:
    return "SystemError";
    break;
  case SWIG_AttributeError:
    return "AttributeError";
    break;
  default:
    return "RuntimeError";
    break;
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
