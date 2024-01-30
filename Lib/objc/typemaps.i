/* -----------------------------------------------------------------------------
 * typemaps.i
 *
 * Pointer and reference handling typemap library
 *
 * These mappings provide support for input/output arguments and common
 * uses for C/C++ pointers and C++ references.
 * ----------------------------------------------------------------------------- */

/*
INPUT typemaps
--------------

These typemaps remap a C pointer or C++ reference to be an "INPUT" value which is
passed by value instead of reference.

The following typemaps can be applied to turn a pointer or reference into a simple
input value.  That is, instead of passing a pointer or reference to an object,
you would use a real value instead.

        bool               *INPUT, bool               &INPUT
        signed char        *INPUT, signed char        &INPUT
        unsigned char      *INPUT, unsigned char      &INPUT
        short              *INPUT, short              &INPUT
        unsigned short     *INPUT, unsigned short     &INPUT
        int                *INPUT, int                &INPUT
        unsigned int       *INPUT, unsigned int       &INPUT
        long               *INPUT, long               &INPUT
        unsigned long      *INPUT, unsigned long      &INPUT
        long long          *INPUT, long long          &INPUT
        unsigned long long *INPUT, unsigned long long &INPUT
        float              *INPUT, float              &INPUT
        double             *INPUT, double             &INPUT
         
To use these, suppose you had a C function like this :

        double fadd(double *a, double *b) {
               return *a+*b;
        }

You could wrap it with SWIG as follows :
        
        %include <typemaps.i>
        double fadd(double *INPUT, double *INPUT);

or you can use the %apply directive :

        %include <typemaps.i>
        %apply double *INPUT { double *a, double *b };
        double fadd(double *a, double *b);

In ObjectiveC you could then use it like this:
        answer = fadd(10.0, 20.0)
*/

%define INPUT_TYPEMAP(TYPE, IMTYPE, OBJCTYPE)
%typemap(imtype) TYPE *INPUT, TYPE &INPUT "IMTYPE"
%typemap(objctype) TYPE *INPUT, TYPE &INPUT "OBJCTYPE"
%typemap(objcin) TYPE *INPUT, TYPE &INPUT "$objcinput"

%typemap(in) TYPE *INPUT,TYPE &INPUT
%{ $1 = ($1_ltype)&$input; %}

%typemap(out) TYPE *INPUT, TYPE &INPUT ""

%enddef

INPUT_TYPEMAP(bool,                 BOOL,                   BOOL);
INPUT_TYPEMAP(signed char,          signed char,            signed char);
INPUT_TYPEMAP(char,                 char,                   char);
INPUT_TYPEMAP(unsigned char,        unsigned char,          unsigned char);
INPUT_TYPEMAP(short,                short,                  short);
INPUT_TYPEMAP(unsigned short,       unsigned short,         unsigned short);
INPUT_TYPEMAP(int,                  int,                    int);
INPUT_TYPEMAP(unsigned int,         unsigned int,           unsigned int);
INPUT_TYPEMAP(long,                 long,                   long);
INPUT_TYPEMAP(unsigned long,        unsigned long,          unsigned long);
INPUT_TYPEMAP(long long,            long long,              long long);
INPUT_TYPEMAP(unsigned long long,   unsigned long long,     unsigned long long);
INPUT_TYPEMAP(float,                float,                  float);
INPUT_TYPEMAP(double,               double,                 double);

/* Override typemaps in the INPUT_TYPEMAP macro for bool represented as BOOL in ObjectiveC */
%typemap(in) bool *INPUT (bool temp), bool &INPUT (bool temp) %{
  temp = ($input) ? true : false;
  $1 = &temp;
%}

#undef INPUT_TYPEMAP

/*
OUTPUT typemaps
---------------

These typemaps are used for parameters that are output only and are mapped to an 
ObjectiveC output parameter.  

The following typemaps can be applied to turn a pointer or reference
into an "output" value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned. 

        bool               *OUTPUT, bool               &OUTPUT
        signed char        *OUTPUT, signed char        &OUTPUT
        unsigned char      *OUTPUT, unsigned char      &OUTPUT
        short              *OUTPUT, short              &OUTPUT
        unsigned short     *OUTPUT, unsigned short     &OUTPUT
        int                *OUTPUT, int                &OUTPUT
        unsigned int       *OUTPUT, unsigned int       &OUTPUT
        long               *OUTPUT, long               &OUTPUT
        unsigned long      *OUTPUT, unsigned long      &OUTPUT
        long long          *OUTPUT, long long          &OUTPUT
        unsigned long long *OUTPUT, unsigned long long &OUTPUT
        float              *OUTPUT, float              &OUTPUT
        double             *OUTPUT, double             &OUTPUT
         
For example, suppose you were trying to wrap the modf() function in the
C math library which splits x into integral and fractional parts (and
returns the integer part in one of its parameters):

        double modf(double x, double *ip);

You could wrap it with SWIG as follows :

        %include <typemaps.i>
        double modf(double x, double *OUTPUT);

or you can use the %apply directive :

        %include <typemaps.i>
        %apply double *OUTPUT { double *ip };
        double modf(double x, double *ip);

The ObjectiveC output of the function would be the function return value and the 
value returned in the second output parameter. In ObjectiveC you would use it like this:

    double *dptr;
    double fraction = modf(5, dptr);
*/

%define OUTPUT_TYPEMAP(TYPE, IMTYPE, OBJCTYPE)
%typemap(imtype) TYPE *OUTPUT, TYPE &OUTPUT "IMTYPE*"
%typemap(objctype) TYPE *OUTPUT, TYPE &OUTPUT "OBJCTYPE*"
%typemap(objcin) TYPE *OUTPUT, TYPE &OUTPUT "$objcinput"

%typemap(in) TYPE *OUTPUT, TYPE &OUTPUT
%{ $1 = ($1_ltype)$input; %}

%enddef

OUTPUT_TYPEMAP(bool,               BOOL,                   BOOL);
OUTPUT_TYPEMAP(signed char,          signed char,            signed char);
OUTPUT_TYPEMAP(char,                 char,                   char);
OUTPUT_TYPEMAP(unsigned char,        unsigned char,          unsigned char);
OUTPUT_TYPEMAP(short,                short,                  short);
OUTPUT_TYPEMAP(unsigned short,       unsigned short,         unsigned short);
OUTPUT_TYPEMAP(int,                  int,                    int);
OUTPUT_TYPEMAP(unsigned int,         unsigned int,           unsigned int);
OUTPUT_TYPEMAP(long,                 long,                   long);
OUTPUT_TYPEMAP(unsigned long,        unsigned long,          unsigned long);
OUTPUT_TYPEMAP(long long,            long long,              long long);
OUTPUT_TYPEMAP(unsigned long long,   unsigned long long,     unsigned long long);
OUTPUT_TYPEMAP(float,                float,                  float);
OUTPUT_TYPEMAP(double,               double,                 double);

#undef OUTPUT_TYPEMAP

/*
 INOUT typemaps
 --------------
 
 These typemaps are for pointer/reference parameters that are both input and
 output and are mapped to a C# reference parameter.
 
 The following typemaps can be applied to turn a pointer or reference into a
 reference parameters, that is the parameter is both an input and an output.
 In C#, the 'ref' keyword is used for reference parameters.
 
 bool               *INOUT, bool               &INOUT
 signed char        *INOUT, signed char        &INOUT
 unsigned char      *INOUT, unsigned char      &INOUT
 short              *INOUT, short              &INOUT
 unsigned short     *INOUT, unsigned short     &INOUT
 int                *INOUT, int                &INOUT
 unsigned int       *INOUT, unsigned int       &INOUT
 long               *INOUT, long               &INOUT
 unsigned long      *INOUT, unsigned long      &INOUT
 long long          *INOUT, long long          &INOUT
 unsigned long long *INOUT, unsigned long long &INOUT
 float              *INOUT, float              &INOUT
 double             *INOUT, double             &INOUT
 
 For example, suppose you were trying to wrap the following function :
 
 void neg(double *x) {
 *x = -(*x);
 }
 
 You could wrap it with SWIG as follows :
 
 %include <typemaps.i>
 void neg(double *INOUT);
 
 or you can use the %apply directive :
 
 %include <typemaps.i>
 %apply double *INOUT { double *x };
 void neg(double *x);
 
 The C# output of the function would be the new value returned by the 
 reference parameter. In C# you would use it like this:
 
 
 double x = 5.0;
 neg(ref x);
 
 The implementation of the OUTPUT and INOUT typemaps is different to the scripting
 languages in that the scripting languages will return the output value as part 
 of the function return value.
 
 */

%define INOUT_TYPEMAP(TYPE, IMTYPE, OBJCTYPE)
%typemap(imtype) TYPE *INOUT, TYPE &INOUT "IMTYPE *"
%typemap(objctype) TYPE *INOUT, TYPE &INOUT "OBJCTYPE *"
%typemap(objcin) TYPE *INOUT, TYPE &INOUT "$objcinput"

%typemap(in) TYPE *INOUT {
  $1 = ($1_ltype) $input;
}

%typemap(in) TYPE &INOUT {
  $1 = ($1_ltype) $input;
}

%enddef

INOUT_TYPEMAP(bool,               BOOL,                   BOOL);
INOUT_TYPEMAP(signed char,          signed char,            signed char);
INOUT_TYPEMAP(char,                 char,                   char);
INOUT_TYPEMAP(unsigned char,        unsigned char,          unsigned char);
INOUT_TYPEMAP(short,                short,                  short);
INOUT_TYPEMAP(unsigned short,       unsigned short,         unsigned short);
INOUT_TYPEMAP(int,                  int,                    int);
INOUT_TYPEMAP(unsigned int,         unsigned int,           unsigned int);
INOUT_TYPEMAP(long,                 long,                   long);
INOUT_TYPEMAP(unsigned long,        unsigned long,          unsigned long);
INOUT_TYPEMAP(long long,            long long,              long long);
INOUT_TYPEMAP(unsigned long long,   unsigned long long,     unsigned long long);
INOUT_TYPEMAP(float,                float,                  float);
INOUT_TYPEMAP(double,               double,                 double);

/* Override typemaps in the INOUT_TYPEMAP macro for bool represented as BOOL in ObjectiveC */
%typemap(in) bool *INOUT (bool temp), bool &INOUT (bool temp) {
  temp = ($input) ? true : false;
  $1 = &temp;
}

#undef INOUT_TYPEMAP
