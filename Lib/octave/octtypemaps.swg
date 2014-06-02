//
// octtypemaps.swg - Octave typemaps
//

// Include fundamental fragment definitions
%include <typemaps/fragments.swg>

// Look for user fragments file
%include <octfragments.swg>

// Octave fragments for primitive types
%include <octprimtypes.swg>

#ifndef SWIG_DIRECTOR_TYPEMAPS
#define SWIG_DIRECTOR_TYPEMAPS
#endif

// Octave types
#define SWIG_Object				octave_value
#define VOID_Object				octave_value()

// Octave allows implicit conversion
//#define %implicitconv_flag			$implicitconv

// Append output
#define SWIG_AppendOutput(result, obj)		SWIG_Octave_AppendOutput(result, obj)

// Set constant
#define SWIG_SetConstant(name, obj)		SWIG_Octave_SetConstant(module_ns,name,obj)

// Raise errors
#define SWIG_Octave_Raise(OBJ, TYPE, DESC)	error("C++ side threw an exception of type " TYPE)
#define SWIG_Raise(obj, type, desc)		SWIG_Octave_Raise(obj, type, desc)

// Include the unified typemap library
%include <typemaps/swigtypemaps.swg>

// Typechecks for Octave types
%typecheck(SWIG_TYPECHECK_SWIGOBJECT) SWIG_Object "$1 = (*$input).is_defined();";
%typecheck(SWIG_TYPECHECK_SWIGOBJECT) octave_value_list "$1 = true;";

// Typemaps for Octave types
%typemap(in) (octave_value_list varargs,...) {
  for (int j=$argnum-1;j<args.length();++j)
    $1.append(args(j));
}
%typecheck(2000) (octave_value_list varargs,...) {
  $1=1;
}
%typemap(in) (const octave_value_list& varargs,...) (octave_value_list tmp) {
  for (int j=$argnum-1;j<args.length();++j)
    tmp.append(args(j));
  $1=&tmp;
}
%typecheck(2000) (const octave_value_list& varargs,...) {
  $1=1;
}
%typemap(out) octave_value_list {
  _outp->append($1);
}
%typemap(out,noblock=1) octave_map, Octave_map {
  $result=$1;
}
%typemap(out,noblock=1) NDArray {
  $result=$1;
}
%typemap(out,noblock=1) Cell {
  $result=$1;
}
