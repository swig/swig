%module langobj


#ifndef SWIG_Object
#define SWIG_Object void *
#endif


%inline %{

#ifdef SWIGTCL
#define SWIG_Object Tcl_Obj *
#endif

#ifdef SWIGPYTHON
#define SWIG_Object PyObject *
#endif

#ifdef SWIGRUBY
#define SWIG_Object VALUE
#endif

#ifndef SWIG_Object
#define SWIG_Object void *
#endif

%}

#ifdef SWIG_JAVASCRIPT_NAPI
// Force sync mode
//
// C/C++ functions that directly manipulate V8 data cannot
// be made async as only a single thread can enter V8
%feature("async", 0) identity;
%feature("sync", 1) identity;
#endif

%inline {

  SWIG_Object identity(SWIG_Object x) {
#ifdef SWIGPYTHON
    Py_XINCREF(x);
#endif
    return x;    
  }

}

  
