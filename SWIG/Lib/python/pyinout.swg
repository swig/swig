//
// Uncomment the following definition if you don't want the in/out
// typemaps by default, ie, you prefer to use typemaps.i.
//
//#define SWIG_INOUT_NODEF

//
// Use the following definition to enable the INPUT parameters to
// accept both 'by value' and 'pointer' objects.
//
#define SWIG_INPUT_ACCEPT_PTRS

// ------------------------------------------------------------------------
// Pointer handling
//
// These mappings provide support for input/output arguments and common
// uses for C/C++ pointers.
// ------------------------------------------------------------------------

// INPUT typemaps.
// These remap a C pointer to be an "INPUT" value which is passed by value
// instead of reference.

/* 
The following methods can be applied to turn a pointer into a simple
"input" value.  That is, instead of passing a pointer to an object,
you would use a real value instead.
         
To use these, suppose you had a C function like this :

        double fadd(double *a, double *b) {
               return *a+*b;
        }

You could wrap it with SWIG as follows :

        double fadd(double *INPUT, double *INPUT);

or you can use the %apply directive :

        %apply double *INPUT { double *a, double *b };
        double fadd(double *a, double *b);

*/
#ifdef SWIG_INPUT_ACCEPT_PTRS
#define SWIG_CheckInputPtr(input,arg,desc,disown) (SWIG_ConvertPtr(input,arg,desc,disown) != -1)
#else
#define SWIG_CheckInputPtr(input,arg,desc,disown) (0)
#endif

%define _PYVAL_INPUT_TYPEMAP(code,as_meth,check_meth,as_frag,check_frag,Type)
  %typemap(in,fragment=as_frag) Type *INPUT ($*1_ltype temp, int res = 0) {
    if (!SWIG_CheckInputPtr($input,(void **)(&$1),$1_descriptor,$disown)) {
      temp = as_meth($input);
      if (PyErr_Occurred()) SWIG_fail;
      $1 = &temp;
      res = SWIG_NEWOBJ;
    }
  }
  %typemap(in,fragment=as_frag) Type &INPUT($*1_ltype temp, int res = 0) {
    if (!SWIG_CheckInputPtr($input,(void **)(&$1),$1_descriptor,$disown)) {
      temp = as_meth($input);
      if (PyErr_Occurred()) SWIG_fail;
      $1 = &temp;
      res = SWIG_NEWOBJ;
    }
    if (!$1) SWIG_fail;
  }
  %typemap(typecheck,precedence=code,fragment=check_frag) Type *INPUT, Type &INPUT {
    void *ptr;
    $1 = (check_meth($input) || (SWIG_CheckInputPtr($input,&ptr,$1_descriptor,0)));
  }
%enddef

%define _PYPTR_INPUT_TYPEMAP(code,asptr_meth,asptr_frag,Type)
  %typemap(in,fragment=asptr_frag) Type *INPUT(int res = 0)
    "if (!(res = asptr_meth($input, &$1))) SWIG_fail;";
  %typemap(in,fragment=asptr_frag) Type &INPUT(int res = 0)
    "if (!(res = asptr_meth($input, &$1)) || !($1)) SWIG_fail;";
  %typemap(freearg) Type *INPUT, Type &INPUT
    "if (res$argnum == SWIG_NEWOBJ) delete $1;";
  %typemap(typecheck,precedence=code,fragment=asptr_frag) Type *INPUT, Type &INPUT
    "$1 = asptr_meth($input, (Type*)0) != 0;"
%enddef

// OUTPUT typemaps.   These typemaps are used for parameters that
// are output only.   The output value is appended to the result as
// a list element.

/* 
The following methods can be applied to turn a pointer into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned.  In the case of
multiple output values, they are returned in the form of a Python tuple.

         
For example, suppose you were trying to wrap the modf() function in the
C math library which splits x into integral and fractional parts (and
returns the integer part in one of its parameters).K:

        double modf(double x, double *ip);

You could wrap it with SWIG as follows :

        double modf(double x, double *OUTPUT);

or you can use the %apply directive :

        %apply double *OUTPUT { double *ip };
        double modf(double x, double *ip);

The Python output of the function would be a tuple containing both
output values. 

*/

// These typemaps contributed by Robin Dunn
//----------------------------------------------------------------------
//
// T_OUTPUT typemap (and helper function) to return multiple argouts as
// a tuple instead of a list.
//
// Author: Robin Dunn
//----------------------------------------------------------------------

%include fragments.i

%define _PYVAL_OUTPUT_TYPEMAP(from_meth, from_frag, Type)
 %typemap(in,numinputs=0) Type *OUTPUT ($*1_ltype temp, int res = 0), 
              Type &OUTPUT ($*1_ltype temp, int res = 0)
   "$1 = &temp; res = SWIG_NEWOBJ;";
 %fragment("t_out_helper"{Type},"header",
	   fragment="t_output_helper",fragment=from_frag) {}
 %typemap(argout,fragment="t_out_helper"{Type}) Type *OUTPUT, Type &OUTPUT 
   "$result = t_output_helper($result, ((res$argnum == SWIG_NEWOBJ) ?
       from_meth((*$1)) : SWIG_NewPointerObj((void*)($1), $1_descriptor, 0)));";

%enddef


// INOUT
// Mappings for an argument that is both an input and output
// parameter

/*
The following methods can be applied to make a function parameter both
an input and output value.  This combines the behavior of both the
"INPUT" and "OUTPUT" methods described earlier.  Output values are
returned in the form of a Python tuple.  
         
For example, suppose you were trying to wrap the following function :

        void neg(double *x) {
             *x = -(*x);
        }

You could wrap it with SWIG as follows :

        void neg(double *INOUT);

or you can use the %apply directive :

        %apply double *INOUT { double *x };
        void neg(double *x);

Unlike C, this mapping does not directly modify the input value (since
this makes no sense in Python).  Rather, the modified input value shows
up as the return value of the function.  Thus, to apply this function
to a Python variable you might do this :

       x = neg(x)

Note : previous versions of SWIG used the symbol 'BOTH' to mark
input/output arguments.   This is still supported, but will be slowly
phased out in future releases.

*/

%define _PYVAL_INOUT_TYPEMAP(Type)
 %typemap(in) Type *INOUT = Type *INPUT;
 %typemap(in) Type &INOUT = Type &INPUT;
 %typemap(typecheck) Type *INOUT = Type *INPUT;
 %typemap(typecheck) Type &INOUT = Type &INPUT;
 %typemap(argout) Type *INOUT = Type *OUTPUT;
 %typemap(argout) Type &INOUT = Type &OUTPUT;
%enddef


%define _PYPTR_INOUT_TYPEMAP(Type)
 _PYVAL_INOUT_TYPEMAP(SWIG_arg(Type))
 %typemap(freearg) Type *INOUT = Type *INPUT;
 %typemap(freearg) Type &INOUT = Type &INPUT;
%enddef

#ifndef SWIG_INOUT_NODEF
#define PYVAL_INPUT_TYPEMAP(code,_a,_c,_af,_cf,...)			        \
  _PYVAL_INPUT_TYPEMAP(SWIG_arg(code),SWIG_arg(_a),SWIG_arg(_c),	\
		       SWIG_arg(_af),SWIG_arg(_cf),SWIG_arg(__VA_ARGS__))

#define PYPTR_INPUT_TYPEMAP(code,_a,_af,...)				\
  _PYPTR_INPUT_TYPEMAP(SWIG_arg(code),SWIG_arg(_a),SWIG_arg(_af),	\
		       SWIG_arg(__VA_ARGS__))

#define PYVAL_OUTPUT_TYPEMAP(_f,_ff,...)				\
  _PYVAL_OUTPUT_TYPEMAP(SWIG_arg(_f),SWIG_arg(_ff),SWIG_arg(__VA_ARGS__))

#define PYVAL_INOUT_TYPEMAP(...) _PYVAL_INOUT_TYPEMAP(SWIG_arg(__VA_ARGS__))
#define PYPTR_INOUT_TYPEMAP(...) _PYPTR_INOUT_TYPEMAP(SWIG_arg(__VA_ARGS__))
#else /* You need to include typemaps.i */
#define PYVAL_OUTPUT_TYPEMAP(...)
#define PYVAL_INPUT_TYPEMAP(...)
#define PYVAL_INOUT_TYPEMAP(...)
#define PYPTR_INPUT_TYPEMAP(...)
#define PYPTR_INOUT_TYPEMAP(...)
#endif /* SWIG_INOUT_DEFAULT */
