/* ------------------------------------------------------------
 *  Typemap specializations for Python
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */
/* bool is dangerous in Python, change precedence */
#undef SWIG_TYPECHECK_BOOL
%define SWIG_TYPECHECK_BOOL             10000 %enddef

/* Include fundamental fragemt definitions */
%include <typemaps/fragments.swg>

/* Look for user fragments file. */
%include <pyfragments.swg>

/* Python fragments for fundamental types */
%include <pyprimtypes.swg>

/* Python fragments for char* strings */
%include <pystrings.swg>

/* Backward compatibility output helper */
%fragment("t_output_helper","header") %{
#define t_output_helper SWIG_Python_AppendOutput
%}


/* ------------------------------------------------------------
 *  Unified typemap section
 * ------------------------------------------------------------ */

/* directors are supported in Python */
#ifndef SWIG_DIRECTOR_TYPEMAPS
#define SWIG_DIRECTOR_TYPEMAPS
#endif


/* Python types */
#define SWIG_Object                     PyObject *
#define VOID_Object                     SWIG_Py_Void()

/* Python allows implicit conversion */
#define %implicitconv_flag              $implicitconv 


/* Overload of the output/constant/exception/dirout handling */

/* append output */
#define SWIG_AppendOutput(result,obj)   SWIG_Python_AppendOutput(result, obj)

/* set constant */
%define %set_constant(name, obj) %begin_block
  PyObject *_obj = obj; 
  PyDict_SetItemString(d, (char*) name, _obj); 
  Py_DECREF(_obj);
%end_block %enddef

/* raise */
%define %raise(obj, type, desc)
  PyObject *_obj = obj; 
  SWIG_PYTHON_THREAD_BEGIN_BLOCK;
  PyErr_SetObject(SWIG_Python_ExceptionType(desc), _obj);
  SWIG_PYTHON_THREAD_END_BLOCK;
  Py_DECREF(_obj);
  SWIG_fail %enddef



/* Include the unified typemap library */
%include <typemaps/swigtypemaps.swg>


/*  ------------------------------------------------------------
 *  Python extra typemaps
 * ------------------------------------------------------------ */

/* Get the address of the 'python self' object */

%typemap(in,numinputs=0,noblock=1) PyObject **PYTHON_SELF {
  $1 = &$self;
}


/* Consttab, needed for callbacks, it should be removed later */

%typemap(consttab) SWIGTYPE ((*)(ANY))  
{ SWIG_PY_POINTER, (char*)"$symname", 0, 0, (void *)($value), &$descriptor }

%typemap(constcode) SWIGTYPE ((*)(ANY)) "";





