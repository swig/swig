
// Include fundamental fragemt definitions
%include <typemaps/fragments.swg>

// Look for user fragments file.
%include <octfragments.swg>

// Octave fragments for primitive types
%include <octprimtypes.swg>

// Octave fragments for char* strings
//%include <octstrings.swg>


#ifndef SWIG_DIRECTOR_TYPEMAPS
#define SWIG_DIRECTOR_TYPEMAPS
#endif

// Octave types
#define SWIG_Object                      octave_value
#define VOID_Object                      octave_value()


// append output
#define SWIG_AppendOutput(result, obj)  SWIG_Octave_AppendOutput(result, obj)

// set constant
#define SWIG_SetConstant(name, obj)     SWIG_Octave_SetConstant(module_ns,name,obj) 

// raise
#define SWIG_Octave_Raise(obj, type, desc) error("c++-side threw an exception")
#define SWIG_Raise(obj, type, desc)     SWIG_Octave_Raise(obj, type, desc)

// Include the unified typemap library
%include <typemaps/swigtypemaps.swg>
