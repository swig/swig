/*  ------------------------------------------------------------
 *
 * Define the IN/OUTPUT typemaps assuming the output parameters are
 * returned in a list, i.e., they are not directly modified.
 *
 * The user should provide the SWIG_append_result(result, obj) method,
 * via a macro, which append a particular object to the result.
 *
 *
 * In Tcl, for example, the file is used as:
 *
 *   #define SWIG_append_result(obj) Tcl_ListObjAppendElement(interp,Tcl_GetObjResult(interp),obj);
 *   %include <typemaps/inoutlist.swg>
 *
 * while in Python it is used as:
 *
 *   #define SWIG_append_result(obj) $result = SWIG_Python_AppendResult($result, obj)
 *   %include <typemaps/inoutlist.swg>
 *
 * where the method SWIG_Python_AppendResult is defined inside the
 * SWIG_append_result fragment.
 *
 * If you forget to define SWIG_append_result, this file will generate
 * an error.
 *
 * ------------------------------------------------------------ */


#ifndef SWIG_append_result
#error Undefined Method SWIG_append_result: used in the OUTPUT typemaps
#endif


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
#define SWIG_CheckInputPtr(input,arg,desc,disown) (SWIG_ConvertPtr(input,SWIG_as_voidptrptr(arg),desc,disown) == SWIG_OK)
#else
#define SWIG_CheckInputPtr(input,arg,desc,disown) (0)
#endif

%define _SWIG_VALUE_INPUT_TYPEMAP(code, asval_meth, asval_frag, Type)
  %typemap(in,noblock=1,fragment=asval_frag) Type *INPUT ($*ltype temp, int res = 0) {
    if (!SWIG_CheckInputPtr($input,&$1,$descriptor,$disown)) {
      Type val; 
      int ecode = asval_meth($input, &val);
      if (ecode != SWIG_OK) { 
	SWIG_arg_fail(ecode, "$*ltype",$argnum);
      }
      temp = SWIG_static_cast(val, $*ltype);
      $1 = &temp;
      res = SWIG_NEWOBJ;
    }
  }
  %typemap(in,noblock=1,fragment=asval_frag) Type &INPUT($*ltype temp, int res = 0) {
    if (!SWIG_CheckInputPtr($input,&$1,$descriptor,$disown)) {
      Type val;
      int ecode = asval_meth($input, &val);
      if (ecode != SWIG_OK) { 
	SWIG_arg_fail(ecode, "$*ltype",$argnum);
      }
      temp = SWIG_static_cast(val, $*ltype);
      $1 = &temp;
      res = SWIG_NEWOBJ;
    }
  }
  %typemap(typecheck,noblock=1,precedence=code,fragment=asval_frag) Type *INPUT, Type &INPUT {
    void *ptr;
    $1 = ((asval_meth($input, 0) == SWIG_OK) || (SWIG_CheckInputPtr($input,&ptr,$1_descriptor,0)));
  }
%enddef

%define _SWIG_PTR_INPUT_TYPEMAP(code,asptr_meth,asptr_frag,Type)
  %typemap(in,noblock=1,fragment=asptr_frag) Type *INPUT(int res = 0) {  
    res = asptr_meth($input, &$1);
    if (!res) {
      SWIG_arg_fail(SWIG_TypeError,"$type",$argnum);
    }
  }
  %typemap(in,noblock=1,fragment=asptr_frag) Type &INPUT(int res = 0) {  
    res = asptr_meth($input, &$1);
    if (!res) { 
      SWIG_arg_fail(SWIG_TypeError,"$type",$argnum);
    }     
    if (!$1) { 
      SWIG_arg_nullref("$type",$argnum);
    }
  }
  %typemap(freearg,noblock=1) Type *INPUT, Type &INPUT {
    if (res$argnum == SWIG_NEWOBJ) SWIG_delete($1);
  }
  %typemap(typecheck,noblock=1,precedence=code,fragment=asptr_frag) Type *INPUT, Type &INPUT {
    $1 = asptr_meth($input, (Type**)0) != 0;
  }
%enddef

// OUTPUT typemaps.   These typemaps are used for parameters that
// are output only.   The output value is appended to the result as
// a list element.

/* 
The following methods can be applied to turn a pointer into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned.  In the case of
multiple output values, they are returned in the form of a list.

         
For example, suppose you were trying to wrap the modf() function in the
C math library which splits x into integral and fractional parts (and
returns the integer part in one of its parameters).K:

        double modf(double x, double *ip);

You could wrap it with SWIG as follows :

        double modf(double x, double *OUTPUT);

or you can use the %apply directive :

        %apply double *OUTPUT { double *ip };
        double modf(double x, double *ip);

The output of the function would be a list containing both output
values.

*/

%define _SWIG_VALUE_OUTPUT_TYPEMAP(from_meth, from_frag, Type)
 %typemap(in,numinputs=0,noblock=1) 
   Type *OUTPUT ($*1_ltype temp, int res = SWIG_NEWOBJ), 
   Type &OUTPUT ($*1_ltype temp, int res = SWIG_NEWOBJ) {
   $1 = &temp;
 }
 %typemap(argout,noblock=1,fragment=from_frag) Type *OUTPUT, Type &OUTPUT {
   SWIG_append_result(((res$argnum == SWIG_NEWOBJ) ?
		       from_meth((*$1)) : SWIG_NewPointerObj((void*)($1), $1_descriptor, 0)));
 }
%enddef


// INOUT
// Mappings for an argument that is both an input and output
// parameter

/*
The following methods can be applied to make a function parameter both
an input and output value.  This combines the behavior of both the
"INPUT" and "OUTPUT" methods described earlier.  Output values are
returned in the form of a list.  
         
For example, suppose you were trying to wrap the following function :

        void neg(double *x) {
             *x = -(*x);
        }

You could wrap it with SWIG as follows :

        void neg(double *INOUT);

or you can use the %apply directive :

        %apply double *INOUT { double *x };
        void neg(double *x);

Unlike C, this mapping does not directly modify the input value.
Rather, the modified input value shows up as the return value of the
function.  Thus, to apply this function to a variable you might do
this :

       x = neg(x)

Note : previous versions of SWIG used the symbol 'BOTH' to mark
input/output arguments.   This is still supported, but will be slowly
phased out in future releases.

*/

%define _SWIG_VALUE_INOUT_TYPEMAP(Type)
 %typemap(in) Type *INOUT = Type *INPUT;
 %typemap(in) Type &INOUT = Type &INPUT;
 %typemap(typecheck) Type *INOUT = Type *INPUT;
 %typemap(typecheck) Type &INOUT = Type &INPUT;
 %typemap(argout) Type *INOUT = Type *OUTPUT;
 %typemap(argout) Type &INOUT = Type &OUTPUT;
%enddef


%define _SWIG_PTR_INOUT_TYPEMAP(Type)
 _SWIG_VALUE_INOUT_TYPEMAP(SWIG_arg(Type))
 %typemap(freearg) Type *INOUT = Type *INPUT;
 %typemap(freearg) Type &INOUT = Type &INPUT;
%enddef

#ifndef SWIG_INOUT_NODEF
#define SWIG_VALUE_INPUT_TYPEMAP(code,_a,_af,...)	        \
  _SWIG_VALUE_INPUT_TYPEMAP(SWIG_arg(code),SWIG_arg(_a),	\
		       SWIG_arg(_af),SWIG_arg(__VA_ARGS__))

#define SWIG_PTR_INPUT_TYPEMAP(code,_a,_af,...)				\
  _SWIG_PTR_INPUT_TYPEMAP(SWIG_arg(code),SWIG_arg(_a),SWIG_arg(_af),	\
		       SWIG_arg(__VA_ARGS__))

#define SWIG_VALUE_OUTPUT_TYPEMAP(_f,_ff,...)				\
  _SWIG_VALUE_OUTPUT_TYPEMAP(SWIG_arg(_f),SWIG_arg(_ff),SWIG_arg(__VA_ARGS__))

#define SWIG_VALUE_INOUT_TYPEMAP(...) _SWIG_VALUE_INOUT_TYPEMAP(SWIG_arg(__VA_ARGS__))
#define SWIG_PTR_INOUT_TYPEMAP(...) _SWIG_PTR_INOUT_TYPEMAP(SWIG_arg(__VA_ARGS__))

#else /* You need to include typemaps.i */


#define SWIG_VALUE_OUTPUT_TYPEMAP(...)
#define SWIG_VALUE_INPUT_TYPEMAP(...)
#define SWIG_VALUE_INOUT_TYPEMAP(...)
#define SWIG_PTR_INPUT_TYPEMAP(...)
#define SWIG_PTR_INOUT_TYPEMAP(...)

#endif /* SWIG_INOUT_DEFAULT */


%define %typemap_inout(Code, AsValMeth, FromMeth, AsValFrag, FromFrag, Type...)
  _SWIG_VALUE_INPUT_TYPEMAP(SWIG_arg(Code), SWIG_arg(AsValMeth), 
			    SWIG_arg(AsValFrag), SWIG_arg(Type));
  _SWIG_VALUE_OUTPUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), SWIG_arg(Type));
  _SWIG_VALUE_INOUT_TYPEMAP(SWIG_arg(Type));
%enddef

%define %typemap_inoutn(Code,Type...)
  %typemap_inout(SWIG_arg(Code),
		 SWIG_arg(SWIG_AsVal(Type)), 
		 SWIG_arg(SWIG_From(Type)), 
		 SWIG_arg(SWIG_AsVal_frag(Type)), 
		 SWIG_arg(SWIG_From_frag(Type)), 
		 SWIG_arg(Type));
%enddef
