//
// SWIG Typemap library
// Dave Beazley
// May 5, 1997
//
// Python implementation
//
// This library provides standard typemaps for modifying SWIG's behavior.
// With enough entries in this file, I hope that very few people actually
// ever need to write a typemap.
//
// Disclaimer : Unless you really understand how typemaps work, this file
// probably isn't going to make much sense.
//

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

         int            *INPUT
         short          *INPUT
         long           *INPUT
	 long long      *INPUT
         unsigned int   *INPUT
         unsigned short *INPUT
         unsigned long  *INPUT
         unsigned long long *INPUT
         unsigned char  *INPUT
         bool           *INPUT
         float          *INPUT
         double         *INPUT
         
To use these, suppose you had a C function like this :

        double fadd(double *a, double *b) {
               return *a+*b;
        }

You could wrap it with SWIG as follows :
        
        %include typemaps.i
        double fadd(double *INPUT, double *INPUT);

or you can use the %apply directive :

        %include typemaps.i
        %apply double *INPUT { double *a, double *b };
        double fadd(double *a, double *b);

*/

%define INPUT_TYPEMAP(type, converter)
%typemap(in) type *INPUT(type temp), type &INPUT(type temp)
{
   temp = converter($input);
   if (PyErr_Occurred()) SWIG_fail;
   $1 = &temp;
}
%typemap(typecheck) type *INPUT = type;
%typemap(typecheck) type &INPUT = type;
%enddef

INPUT_TYPEMAP(float, PyFloat_AsDouble);
INPUT_TYPEMAP(double, PyFloat_AsDouble);
INPUT_TYPEMAP(int, PyInt_AsLong);
INPUT_TYPEMAP(short, PyInt_AsLong);
INPUT_TYPEMAP(long, PyInt_AsLong);
INPUT_TYPEMAP(long long, PyLong_AsLongLong);
INPUT_TYPEMAP(unsigned int, PyInt_AsLong);
INPUT_TYPEMAP(unsigned short, PyInt_AsLong);
INPUT_TYPEMAP(unsigned long, PyInt_AsLong);
INPUT_TYPEMAP(unsigned long long, PyLong_AsUnsignedLongLong);
INPUT_TYPEMAP(unsigned char, PyInt_AsLong);
INPUT_TYPEMAP(signed char, PyInt_AsLong);

#undef INPUT_TYPEMAP

%typemap(in) bool *INPUT(bool temp), bool &INPUT(bool temp)
{
   temp = PyInt_AsLong($input) ? true : false;
   if (PyErr_Occurred()) SWIG_fail;
   $1 = &temp;
}
%typemap(typecheck) bool *INPUT = bool;
%typemap(typecheck) bool &INPUT = bool;

// OUTPUT typemaps.   These typemaps are used for parameters that
// are output only.   The output value is appended to the result as
// a list element.

/* 
The following methods can be applied to turn a pointer into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned.  In the case of
multiple output values, they are returned in the form of a Python tuple.

         int            *OUTPUT
         short          *OUTPUT
         long           *OUTPUT
         long long      *OUTPUT
         unsigned int   *OUTPUT
         unsigned short *OUTPUT
         unsigned long  *OUTPUT
         unsigned long long *OUTPUT
         unsigned char  *OUTPUT
         bool           *OUTPUT
         float          *OUTPUT
         double         *OUTPUT
         
For example, suppose you were trying to wrap the modf() function in the
C math library which splits x into integral and fractional parts (and
returns the integer part in one of its parameters).K:

        double modf(double x, double *ip);

You could wrap it with SWIG as follows :

        %include typemaps.i
        double modf(double x, double *OUTPUT);

or you can use the %apply directive :

        %include typemaps.i
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

%include "fragments.i"

%define OUTPUT_TYPEMAP(type, converter, convtype)
%typemap(in,numinputs=0) type *OUTPUT(type temp), type &OUTPUT(type temp) "$1 = &temp;";
%typemap(argout,fragment="t_output_helper") type *OUTPUT, type &OUTPUT {
   PyObject *o = converter(convtype (*$1));
   $result = t_output_helper($result,o);
}
%enddef

OUTPUT_TYPEMAP(int, PyInt_FromLong, (long));
OUTPUT_TYPEMAP(short, PyInt_FromLong, (long));
OUTPUT_TYPEMAP(long, PyInt_FromLong, (long));
OUTPUT_TYPEMAP(long long, PyLong_FromLongLong, (long long));
OUTPUT_TYPEMAP(unsigned int, PyInt_FromLong, (long));
OUTPUT_TYPEMAP(unsigned short, PyInt_FromLong, (long));
OUTPUT_TYPEMAP(unsigned long, PyInt_FromLong, (long));
OUTPUT_TYPEMAP(unsigned long long, PyLong_FromUnsignedLongLong, (unsigned long long));
OUTPUT_TYPEMAP(unsigned char, PyInt_FromLong, (long));
OUTPUT_TYPEMAP(signed char, PyInt_FromLong, (long));
OUTPUT_TYPEMAP(bool, PyInt_FromLong, (long));
OUTPUT_TYPEMAP(float, PyFloat_FromDouble, (double));
OUTPUT_TYPEMAP(double, PyFloat_FromDouble, (double));

#undef OUTPUT_TYPEMAP

// INOUT
// Mappings for an argument that is both an input and output
// parameter

/*
The following methods can be applied to make a function parameter both
an input and output value.  This combines the behavior of both the
"INPUT" and "OUTPUT" methods described earlier.  Output values are
returned in the form of a Python tuple.  

         int            *INOUT
         short          *INOUT
         long           *INOUT
         long long      *INOUT
         unsigned int   *INOUT
         unsigned short *INOUT
         unsigned long  *INOUT
         unsigned long long *INOUT
         unsigned char  *INOUT
         bool           *INOUT
         float          *INOUT
         double         *INOUT
         
For example, suppose you were trying to wrap the following function :

        void neg(double *x) {
             *x = -(*x);
        }

You could wrap it with SWIG as follows :

        %include typemaps.i
        void neg(double *INOUT);

or you can use the %apply directive :

        %include typemaps.i
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

%typemap(in) int *INOUT = int *INPUT;
%typemap(in) short *INOUT = short *INPUT;
%typemap(in) long *INOUT = long *INPUT;
%typemap(in) long long *INOUT = long long *INPUT;
%typemap(in) unsigned *INOUT = unsigned *INPUT;
%typemap(in) unsigned short *INOUT = unsigned short *INPUT;
%typemap(in) unsigned long *INOUT = unsigned long *INPUT;
%typemap(in) unsigned long long *INOUT = unsigned long long *INPUT;
%typemap(in) unsigned char *INOUT = unsigned char *INPUT;
%typemap(in) bool *INOUT = bool *INPUT;
%typemap(in) float *INOUT = float *INPUT;
%typemap(in) double *INOUT = double *INPUT;

%typemap(in) int &INOUT = int &INPUT;
%typemap(in) short &INOUT = short &INPUT;
%typemap(in) long &INOUT = long &INPUT;
%typemap(in) long long &INOUT = long long &INPUT;
%typemap(in) unsigned &INOUT = unsigned &INPUT;
%typemap(in) unsigned short &INOUT = unsigned short &INPUT;
%typemap(in) unsigned long &INOUT = unsigned long &INPUT;
%typemap(in) unsigned long long &INOUT = unsigned long long &INPUT;
%typemap(in) unsigned char &INOUT = unsigned char &INPUT;
%typemap(in) bool &INOUT = bool &INPUT;
%typemap(in) float &INOUT = float &INPUT;
%typemap(in) double &INOUT = double &INPUT;

%typemap(argout) int *INOUT = int *OUTPUT;
%typemap(argout) short *INOUT = short *OUTPUT;
%typemap(argout) long *INOUT = long *OUTPUT;
%typemap(argout) long long *INOUT = long long *OUTPUT;
%typemap(argout) unsigned *INOUT = unsigned *OUTPUT;
%typemap(argout) unsigned short *INOUT = unsigned short *OUTPUT;
%typemap(argout) unsigned long *INOUT = unsigned long *OUTPUT;
%typemap(argout) unsigned long long *INOUT = unsigned long long *OUTPUT;
%typemap(argout) unsigned char *INOUT = unsigned char *OUTPUT;
%typemap(argout) bool *INOUT = bool *OUTPUT;
%typemap(argout) float *INOUT = float *OUTPUT;
%typemap(argout) double *INOUT = double *OUTPUT;

%typemap(argout) int &INOUT = int &OUTPUT;
%typemap(argout) short &INOUT = short &OUTPUT;
%typemap(argout) long &INOUT = long &OUTPUT;
%typemap(argout) long long &INOUT = long long &OUTPUT;
%typemap(argout) unsigned &INOUT = unsigned &OUTPUT;
%typemap(argout) unsigned short &INOUT = unsigned short &OUTPUT;
%typemap(argout) unsigned long &INOUT = unsigned long &OUTPUT;
%typemap(argout) unsigned long long &INOUT = unsigned long long &OUTPUT;
%typemap(argout) unsigned char &INOUT = unsigned char &OUTPUT;
%typemap(argout) bool &INOUT = bool &OUTPUT;
%typemap(argout) float &INOUT = float &OUTPUT;
%typemap(argout) double &INOUT = double &OUTPUT;

/* Overloading information */

%typemap(typecheck) double *INOUT = double;
%typemap(typecheck) bool *INOUT = bool;
%typemap(typecheck) signed char *INOUT = signed char;
%typemap(typecheck) unsigned char *INOUT = unsigned char;
%typemap(typecheck) unsigned long *INOUT = unsigned long;
%typemap(typecheck) unsigned long long *INOUT = unsigned long long;
%typemap(typecheck) unsigned short *INOUT = unsigned short;
%typemap(typecheck) unsigned int *INOUT = unsigned int;
%typemap(typecheck) long *INOUT = long;
%typemap(typecheck) long long *INOUT = long long;
%typemap(typecheck) short *INOUT = short;
%typemap(typecheck) int *INOUT = int;
%typemap(typecheck) float *INOUT = float;

%typemap(typecheck) double &INOUT = double;
%typemap(typecheck) bool &INOUT = bool;
%typemap(typecheck) signed char &INOUT = signed char;
%typemap(typecheck) unsigned char &INOUT = unsigned char;
%typemap(typecheck) unsigned long &INOUT = unsigned long;
%typemap(typecheck) unsigned long long &INOUT = unsigned long long;
%typemap(typecheck) unsigned short &INOUT = unsigned short;
%typemap(typecheck) unsigned int &INOUT = unsigned int;
%typemap(typecheck) long &INOUT = long;
%typemap(typecheck) long long &INOUT = long long;
%typemap(typecheck) short &INOUT = short;
%typemap(typecheck) int &INOUT = int;
%typemap(typecheck) float &INOUT = float;





