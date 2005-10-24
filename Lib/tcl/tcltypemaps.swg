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

#define SWIG_Object                      Tcl_Obj *
#define VOID_Object                      NULL

#define SWIG_AppendOutput(result,obj)    (Tcl_ListObjAppendElement(NULL,result,obj) == TCL_OK) ? result : NULL
#define SWIG_SetConstant(name, obj)      SWIG_Tcl_SetConstantObj(interp, name, obj)
#define SWIG_Raise(obj,type,desc)        SWIG_Tcl_SetErrorObj(interp,type,obj)

/* -----------------------------------------------------------------------------
 *  All the typemaps
 * ----------------------------------------------------------------------------- */

%include <tclprimtypes.swg>
%include <tclstrings.swg>
%include <typemaps/swigtypemaps.swg>

/* fix for instances */
%include <tclswigtype.swg>

