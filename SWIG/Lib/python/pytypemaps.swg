/* -----------------------------------------------------------------------------
 *  Typemap specializations
 * ----------------------------------------------------------------------------- */

/* directors are supported in Python */
#ifndef SWIG_DIRECTOR_TYPEMAPS
#define SWIG_DIRECTOR_TYPEMAPS
#endif

/* bool is dangerous in Python -> C++, change precedence */
#undef SWIG_TYPECHECK_BOOL
%define SWIG_TYPECHECK_BOOL         10000 %enddef


/* -----------------------------------------------------------------------------
 *  Basic definitions
 * ----------------------------------------------------------------------------- */

%define_swig_object(PyObject *)

#define SWIG_SetResultObj(obj)             $result = obj
#define SWIG_AppendResultObj(obj)          $result = SWIG_Python_AppendResult($result, obj)
#define SWIG_SetConstantObj(name, obj)     PyDict_SetItemString(d, name, obj);
#define SWIG_NoneObject()                  SWIG_Python_NoneObject()

/* error manipulation */
#define SWIG_ErrorType(code)               SWIG_Python_ErrorType(code)
#define SWIG_SetErrorObj(code, obj)        PyErr_SetObject(SWIG_ErrorType(code), obj)
#define SWIG_SetErrorMsg(code, msg)        SWIG_Python_SetErrorMsg(SWIG_ErrorType(code),msg)
#define SWIG_ExceptionObj(desc, type, obj) SWIG_Python_SetExceptionObj(desc, obj)
#define SWIG_DirOutFail(code, msg)         Swig::DirectorTypeMismatchException::raise(SWIG_ErrorType(code), msg)


/* -----------------------------------------------------------------------------
 *  All the typemaps
 * ----------------------------------------------------------------------------- */


%fragment("t_output_helper","header") %{
#define t_output_helper SWIG_Python_AppendResult
%}


%include "pyfragments.swg"

%include <pyswigtype.swg>
%include <typemaps/void.swg>
%include <typemaps/valtypes.swg>
%include <typemaps/ptrtypes.swg>
%include <typemaps/swigobject.swg>
%include <typemaps/inoutlist.swg>
%include <pyprimtypes.swg>
%include <pystrings.swg>
%include <typemaps/misctypes.swg>
%include <typemaps/enumint.swg>

