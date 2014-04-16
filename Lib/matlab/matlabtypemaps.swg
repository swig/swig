
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
#define SWIG_AppendOutput(result, obj)  SWIG_Octave_AppendOutput(result, obj)

// set constant
#define SWIG_SetConstant(name, obj)     SWIG_Matlab_SetConstant(module_ns,name,obj) 

// raise
#define SWIG_Octave_Raise(OBJ, TYPE, DESC) error("C++ side threw an exception of type " TYPE)
#define SWIG_Raise(obj, type, desc)     SWIG_Octave_Raise(obj, type, desc)

// Include the unified typemap library
%include <typemaps/swigtypemaps.swg>

%typecheck(SWIG_TYPECHECK_SWIGOBJECT) SWIG_Object "$1 = (*$input).is_defined();";
%typecheck(SWIG_TYPECHECK_SWIGOBJECT) octave_value_list "$1 = true;";

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
