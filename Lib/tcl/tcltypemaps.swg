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

#define SWIG_VoidObject()                NULL
#define SWIG_SetResultObj(obj)           $result = obj
#define SWIG_AppendResultObj(obj)        $result = (Tcl_ListObjAppendElement(NULL,$result,obj) == TCL_OK) ? $result : NULL
#define SWIG_SetConstantObj(name, obj)   SWIG_Tcl_SetConstantObj(interp, name, obj)
#define SWIG_Raise(obj,type,desc)        SWIG_Tcl_SetErrorObj(interp,type,obj)
#define SWIG_DirOutFail(code, msg)       /* no directors supported */

/* -----------------------------------------------------------------------------
 *  All the typemaps
 * ----------------------------------------------------------------------------- */

%include "tclfragments.swg"

%include <typemaps/exception.swg>
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
