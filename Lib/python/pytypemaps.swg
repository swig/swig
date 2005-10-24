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

#define SWIG_Object                     PyObject *
#define VOID_Object                     (Py_INCREF(Py_None) ? Py_None : 0)

#define SWIG_AppendOutput(result,obj)   SWIG_Python_AppendOutput(result, obj)
#define SWIG_SetConstant(name, obj)     %block(PyObject *_obj = obj; PyDict_SetItemString(d, name, _obj); Py_DECREF(_obj))
#define SWIG_Raise(obj, type, desc)     PyObject *_obj = obj; PyErr_SetObject(SWIG_Python_ExceptionType(desc), _obj); Py_DECREF(_obj)
#define SWIG_DirOutFail(code, msg)      Swig::DirectorTypeMismatchException::raise(SWIG_ErrorType(code), msg)


/* -----------------------------------------------------------------------------
 *  All the typemaps
 * ----------------------------------------------------------------------------- */

%include <pyprimtypes.swg>
%include <pystrings.swg>
%include <typemaps/swigtypemaps.swg>

/* fix for callbacks */
%include <pyswigtype.swg>

/* -----------------------------------------------------------------------------
 * Backward compatibility output helper 
 * ----------------------------------------------------------------------------- */
%fragment("t_output_helper","header") %{
#define t_output_helper SWIG_Python_AppendOutput
%}

