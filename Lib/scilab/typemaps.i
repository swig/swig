/* -----------------------------------------------------------------------------
 * typemaps.i
 *
 * The SWIG typemap library provides a language independent mechanism for
 * supporting output arguments, input values, and other C function
 * calling mechanisms.  The primary use of the library is to provide a
 * better interface to certain C function--especially those involving
 * pointers.
 * ----------------------------------------------------------------------------- */

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

%typemap(in, noblock=1, fragment=SWIG_AsVal_frag(int)) int *INPUT(int temp), int &INPUT(int temp) {
  if (SWIG_AsVal_dec(int)($input, &temp) != SWIG_OK) {
    SWIG_fail;
  }
  $1 = &temp;
}

%typemap(freearg, noblock=1) int *INPUT, int &INPUT {
}

//short          *INPUT
//long           *INPUT
//long long      *INPUT
//unsigned int   *INPUT
//unsigned short *INPUT
//unsigned long  *INPUT
//unsigned long long *INPUT
//unsigned char  *INPUT
//bool           *INPUT
//float          *INPUT

%typemap(in, noblock=1, fragment=SWIG_AsVal_frag(double)) double *INPUT(double temp), double &INPUT(double temp) {
  if (SWIG_AsVal_dec(double)($input, &temp) != SWIG_OK) {
    SWIG_fail;
  }
  $1 = &temp;
}

%typemap(freearg, noblock=1) double *INPUT, double &INPUT {
}

// OUTPUT typemaps.   These typemaps are used for parameters that
// are output only.   The output value is appended to the result as
// a list element.

/*
The following methods can be applied to turn a pointer into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned.  In the case of
multiple output values, functions will return a Scilab array.

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
returns the integer part in one of its parameters).:

        double modf(double x, double *ip);

You could wrap it with SWIG as follows :

        %include typemaps.i
        double modf(double x, double *OUTPUT);

or you can use the %apply directive :

        %include typemaps.i
        %apply double *OUTPUT { double *ip };
        double modf(double x, double *ip);

The Scilab output of the function would be an array containing both
output values.

*/

%typemap(argout, noblock=1, fragment=SWIG_From_frag(int)) int *OUTPUT, int &OUTPUT {
  %set_output(SWIG_From_dec(int)(*$1));
}
//short          *OUTPUT
//long           *OUTPUT
//long long      *OUTPUT
//unsigned int   *OUTPUT
//unsigned short *OUTPUT
//unsigned long  *OUTPUT
//unsigned long long *OUTPUT
//unsigned char  *OUTPUT
//bool           *OUTPUT
//float          *OUTPUT
//double         *OUTPUT
%typemap(argout, noblock=1, fragment=SWIG_From_frag(double)) double *OUTPUT, double &OUTPUT {
    %set_output(SWIG_From_dec(double)(*$1));
}

// INOUT
// Mappings for an argument that is both an input and output
// parameter

/*
The following methods can be applied to make a function parameter both
an input and output value.  This combines the behavior of both the
"INPUT" and "OUTPUT" methods described earlier.  Output values are
returned in the form of a Scilab array.

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

Unlike C, this mapping does not directly modify the input value.
Rather, the modified input value shows up as the return value of the
function.  Thus, to apply this function to a Scilab variable you might
do this :

       $x = neg($x);

*/

%typemap(in) int *INOUT = int *INPUT;
%typemap(in) short *INOUT = short *INPUT;
%typemap(in) long *INOUT = long *INPUT;
%typemap(in) unsigned *INOUT = unsigned *INPUT;
%typemap(in) unsigned short *INOUT = unsigned short *INPUT;
%typemap(in) unsigned long *INOUT = unsigned long *INPUT;
%typemap(in) unsigned char *INOUT = unsigned char *INPUT;
%typemap(in) signed char *INOUT = signed char *INPUT;
%typemap(in) float *INOUT = float *INPUT;
%typemap(in) double *INOUT = double *INPUT;

%typemap(in) int *INOUT = int *OUTPUT;
%typemap(in) short *INOUT = short *OUTPUT;
%typemap(in) long *INOUT = long *INPUT;
%typemap(in) unsigned *INOUT = unsigned *OUTPUT;
%typemap(in) unsigned short *INOUT = unsigned short *OUTPUT;
%typemap(in) unsigned long *INOUT = unsigned long *OUTPUT;
%typemap(in) unsigned char *INOUT = unsigned char *OUTPUT;
%typemap(in) signed char *INOUT = signed char *OUTPUT;
%typemap(in) float *INOUT = float *OUTPUT;
%typemap(in) double *INOUT = double *OUTPUT;

