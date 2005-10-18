/* -----------------------------------------------------------------------------
 *  Typemap specializations
 * ----------------------------------------------------------------------------- */

/* no director supported in Tcl */
#ifdef SWIG_DIRECTOR_TYPEMAPS
#undef SWIG_DIRECTOR_TYPEMAPS
#endif

/* -----------------------------------------------------------------------------
 *  Basic definitions
 * ----------------------------------------------------------------------------- */

%define_swig_object(Tcl_Obj *)

#define SWIG_SetResultObj(obj)           $result = obj
#define SWIG_AppendResultObj(obj)        $result = (Tcl_ListObjAppendElement(NULL,$result,obj) == TCL_OK) ? $result : NULL;
#define SWIG_SetConstantObj(name, obj)   SWIG_Tcl_SetConstantObj(interp, name, obj)
#define SWIG_NoneObject()                NULL

/* error manipulation */
#define SWIG_ErrorType(code)           SWIG_Tcl_ErrorType(code)
#define SWIG_SetErrorObj(code,obj)     SWIG_Tcl_SetErrorObj(interp,SWIG_ErrorType(code),obj)
#define SWIG_SetErrorMsg(code,msg)     SWIG_Tcl_SetErrorMsg(interp,SWIG_ErrorType(code),msg)
#define SWIG_ExceptionObj(d,type,obj)  SWIG_Tcl_SetErrorObj(interp,type,obj)

/* -----------------------------------------------------------------------------
 *  All the typemaps
 * ----------------------------------------------------------------------------- */

%include "tclfragments.swg"

%include <tclswigtype.swg>
%include <typemaps/void.swg>
%include <typemaps/valtypes.swg>
%include <typemaps/ptrtypes.swg>
%include <typemaps/swigobject.swg>
%include <typemaps/inoutlist.swg>
%include <tclprimtypes.swg>
%include <tclstrings.swg>
%include <typemaps/misctypes.swg>
%include <typemaps/enumint.swg>
