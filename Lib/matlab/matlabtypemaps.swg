
// Include fundamental fragment definitions
%include <typemaps/fragments.swg>

// Look for user fragments file.
%include <matlabfragments.swg>

// MATLAB fragments for primitive types
%include <matlabprimtypes.swg>

// MATLAB types
#define SWIG_Object mxArray*
#define VOID_Object (mxArray*)0

// append output
#define SWIG_AppendOutput(result, obj)  obj

// set constant
#define SWIG_SetConstant(name, obj)     SWIG_Matlab_SetConstant(module_ns,name,obj)

// raise
#define SWIG_Matlab_Raise(OBJ, TYPE, DESC) SWIG_Matlab_ErrorId("SWIG:RuntimeError", "C++ side threw an exception of type " TYPE)
#define SWIG_Raise(obj, type, desc)     SWIG_Matlab_Raise(obj, type, desc)

/* directors are supported in Matlab */
#ifndef SWIG_DIRECTOR_TYPEMAPS
#define SWIG_DIRECTOR_TYPEMAPS
#endif

// Include the unified typemap library
%include <typemaps/swigtypemaps.swg>
%include <matlabenum.swg>

/* Raw mxArray handles accept all values, including Octave classdef objects
 * whose class ID is mxUNKNOWN_CLASS. */
%typecheck(SWIG_TYPECHECK_SWIGOBJECT) SWIG_Object "$1 = $input != NULL;";
