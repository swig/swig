//
// typemaps for Ruby
//
// $Header$
//
// Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
// Copyright (C) 2000  Information-technology Promotion Agency, Japan
//
// Masaki Fukushima
//

/*
The SWIG typemap library provides a language independent mechanism for
supporting output arguments, input values, and other C function
calling mechanisms.  The primary use of the library is to provide a
better interface to certain C function--especially those involving
pointers.
*/

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
         unsigned int   *INPUT
         unsigned short *INPUT
         unsigned long  *INPUT
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

%typemap(in) double *INPUT(double temp), double &INPUT(double temp)
{
  temp = NUM2DBL($input);
  $1 = &temp;
}

%typemap(in) float *INPUT(float temp), float &INPUT(float temp)
{
  temp = (float) NUM2DBL($input);
  $1 = &temp;
}

%typemap(in) int *INPUT(int temp), int &INPUT(int temp)
{
  temp = NUM2INT($input);
  $1 = &temp;
}

%typemap(in) short *INPUT(short temp), short &INPUT(short temp)
{
  temp = NUM2SHRT($input);
  $1 = &temp;
}

%typemap(in) long *INPUT(long temp), long &INPUT(long temp)
{
  temp = NUM2LONG($input);
  $1 = &temp;
}

%typemap(in) unsigned int *INPUT(unsigned int temp), unsigned int &INPUT(unsigned int temp)
{
  temp = NUM2UINT($input);
  $1 = &temp;
}

%typemap(in) unsigned short *INPUT(unsigned short temp), unsigned short &INPUT(unsigned short temp)
{
  temp = NUM2USHRT($input);
  $1 = &temp;
}

%typemap(in) unsigned long *INPUT(unsigned long temp), unsigned long &INPUT(unsigned long temp)
{
  temp = NUM2ULONG($input);
  $1 = &temp;
}

%typemap(in) unsigned char *INPUT(unsigned char temp), unsigned char &INPUT(unsigned char temp)
{
  temp = (unsigned char)NUM2UINT($input);
  $1 = &temp;
}

%typemap(in) signed char *INPUT(signed char temp), signed char &INPUT(signed char temp)
{
  temp = (signed char)NUM2INT($input);
  $1 = &temp;
}
                 
%typemap(in) bool *INPUT(bool temp), bool &INPUT(bool temp)
{
  temp = RTEST($input);
  $1 = &temp;
}

// OUTPUT typemaps.   These typemaps are used for parameters that
// are output only.   The output value is appended to the result as
// a array element.

/*
The following methods can be applied to turn a pointer into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned.  In the case of
multiple output values, they are returned in the form of a Ruby Array.

         int            *OUTPUT
         short          *OUTPUT
         long           *OUTPUT
         unsigned int   *OUTPUT
         unsigned short *OUTPUT
         unsigned long  *OUTPUT
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

The Ruby output of the function would be a Array containing both
output values. 
*/

// Helper function for Array output

%{
static VALUE output_helper(VALUE target, VALUE o) {
    if (NIL_P(target)) {
	target = o;
    } else {
	if (TYPE(target) != T_ARRAY) {
	    VALUE o2 = target;
	    target = rb_ary_new();
	    rb_ary_push(target, o2);
	}
	rb_ary_push(target, o);
    }
    return target;
}
%}

// Force the argument to be ignored.

%typemap(ignore) int            *OUTPUT(int temp),
                 short          *OUTPUT(short temp),
                 long           *OUTPUT(long temp),
                 unsigned int   *OUTPUT(unsigned int temp),
                 unsigned short *OUTPUT(unsigned short temp),
                 unsigned long  *OUTPUT(unsigned long temp),
                 unsigned char  *OUTPUT(unsigned char temp),
                 signed char    *OUTPUT(signed char temp),
		 bool           *OUTPUT(bool temp),
                 float          *OUTPUT(float temp),
                 double         *OUTPUT(double temp),
                 int            &OUTPUT(int temp),
                 short          &OUTPUT(short temp),
                 long           &OUTPUT(long temp),
                 unsigned int   &OUTPUT(unsigned int temp),
                 unsigned short &OUTPUT(unsigned short temp),
                 unsigned long  &OUTPUT(unsigned long temp),
                 unsigned char  &OUTPUT(unsigned char temp),
                 signed char    &OUTPUT(signed char temp),
		 bool           &OUTPUT(bool temp),
                 float          &OUTPUT(float temp),
                 double         &OUTPUT(double temp)
"$1 = &temp;";

%typemap(argout) int            *OUTPUT, int &OUTPUT,
                 short          *OUTPUT, short &OUTPUT,
                 long           *OUTPUT, long  &OUTPUT,
                 signed char    *OUTPUT,  signed char &OUTPUT
"$result = output_helper($result, INT2NUM(*$1));";

%typemap(argout) unsigned int   *OUTPUT, unsigned int &OUTPUT,
                 unsigned short *OUTPUT, unsigned short &OUTPUT,
                 unsigned long  *OUTPUT, unsigned long &OUTPUT,
                 unsigned char  *OUTPUT, unsigned char &OUTPUT
"$result = output_helper($result, UINT2NUM(*$1));";

%typemap(argout) float    *OUTPUT, float &OUTPUT,
                 double   *OUTPUT, double &OUTPUT
"$result = output_helper($result, rb_float_new(*$1));";

%typemap(argout) bool *OUTPUT, bool &OUTPUT
"$result = output_helper($result, (*$1) ? Qtrue : Qfalse);";

// INOUT
// Mappings for an argument that is both an input and output
// parameter

/*
The following methods can be applied to make a function parameter both
an input and output value.  This combines the behavior of both the
"INPUT" and "OUTPUT" methods described earlier.  Output values are
returned in the form of a Ruby array.

         int            *INOUT
         short          *INOUT
         long           *INOUT
         unsigned int   *INOUT
         unsigned short *INOUT
         unsigned long  *INOUT
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
this makes no sense in Ruby).  Rather, the modified input value shows
up as the return value of the function.  Thus, to apply this function
to a Ruby variable you might do this :

       x = neg(x)

Note : previous versions of SWIG used the symbol 'BOTH' to mark
input/output arguments.   This is still supported, but will be slowly
phased out in future releases.

*/

%typemap(in) int *INOUT = int *INPUT;
%typemap(in) short *INOUT = short *INPUT;
%typemap(in) long *INOUT = long *INPUT;
%typemap(in) unsigned *INOUT = unsigned *INPUT;
%typemap(in) unsigned short *INOUT = unsigned short *INPUT;
%typemap(in) unsigned long *INOUT = unsigned long *INPUT;
%typemap(in) unsigned char *INOUT = unsigned char *INPUT;
%typemap(in) signed char *INOUT = signed char *INPUT;
%typemap(in) bool *INOUT = bool *INPUT;
%typemap(in) float *INOUT = float *INPUT;
%typemap(in) double *INOUT = double *INPUT;

%typemap(in) int &INOUT = int &INPUT;
%typemap(in) short &INOUT = short &INPUT;
%typemap(in) long &INOUT = long &INPUT;
%typemap(in) unsigned &INOUT = unsigned &INPUT;
%typemap(in) unsigned short &INOUT = unsigned short &INPUT;
%typemap(in) unsigned long &INOUT = unsigned long &INPUT;
%typemap(in) unsigned char &INOUT = unsigned char &INPUT;
%typemap(in) signed char &INOUT = signed char &INPUT;
%typemap(in) bool &INOUT = bool &INPUT;
%typemap(in) float &INOUT = float &INPUT;
%typemap(in) double &INOUT = double &INPUT;

%typemap(argout) int *INOUT = int *OUTPUT;
%typemap(argout) short *INOUT = short *OUTPUT;
%typemap(argout) long *INOUT = long *OUTPUT;
%typemap(argout) unsigned *INOUT = unsigned *OUTPUT;
%typemap(argout) unsigned short *INOUT = unsigned short *OUTPUT;
%typemap(argout) unsigned long *INOUT = unsigned long *OUTPUT;
%typemap(argout) unsigned char *INOUT = unsigned char *OUTPUT;
%typemap(argout) signed char *INOUT = signed char *OUTPUT;
%typemap(argout) bool *INOUT = bool *OUTPUT;
%typemap(argout) float *INOUT = float *OUTPUT;
%typemap(argout) double *INOUT = double *OUTPUT;

%typemap(argout) int &INOUT = int &OUTPUT;
%typemap(argout) short &INOUT = short &OUTPUT;
%typemap(argout) long &INOUT = long &OUTPUT;
%typemap(argout) unsigned &INOUT = unsigned &OUTPUT;
%typemap(argout) unsigned short &INOUT = unsigned short &OUTPUT;
%typemap(argout) unsigned long &INOUT = unsigned long &OUTPUT;
%typemap(argout) unsigned char &INOUT = unsigned char &OUTPUT;
%typemap(argout) signed char &INOUT = signed char &OUTPUT;
%typemap(argout) bool &INOUT = bool &OUTPUT;
%typemap(argout) float &INOUT = float &OUTPUT;
%typemap(argout) double &INOUT = double &OUTPUT;

// --------------------------------------------------------------------
// Special types
// --------------------------------------------------------------------

/*
The typemaps.i library also provides the following mappings :

struct timeval *
time_t

    Ruby has builtin class Time.  INPUT/OUTPUT typemap for timeval and
    time_t is provided.

int PROG_ARGC
char **PROG_ARGV

    Some C function receive argc and argv from C main function.
    This typemap provides ignore typemap which pass Ruby ARGV contents
    as argc and argv to C function.
*/


// struct timeval *
%{
#ifdef __cplusplus
extern "C" {
#endif
#ifdef HAVE_SYS_TIME_H
# include <sys/time.h>
struct timeval rb_time_timeval(VALUE);
#endif
#ifdef __cplusplus
}
#endif
%}

%typemap(in) struct timeval *INPUT (struct timeval temp)
{
    if (NIL_P($input))
	$1 = NULL;
    else {
	temp = rb_time_timeval($input);
	$1 = &temp;
    }
}

%typemap(ignore) struct timeval *OUTPUT(struct timeval temp)
{
    $1 = &temp;
}

%typemap(argout) struct timeval *OUTPUT
{
    $result = rb_time_new($1->tv_sec, $1->tv_usec);
}

%typemap(out) struct timeval *
{
    $result = rb_time_new($1->tv_sec, $1->tv_usec);
}

%typemap(out) struct timespec *
{
    $result = rb_time_new($1->tv_sec, $1->tv_nsec / 1000);
}

// time_t
%typemap(in) time_t
{
    if (NIL_P($input))
	$1 = (time_t)-1;
    else
	$1 = NUM2LONG(rb_funcall($input, rb_intern("tv_sec"), 0));
}

%typemap(out) time_t
{
    $result = rb_time_new($1, 0);
}

// argc and argv
%typemap(ignore) int PROG_ARGC {
    $1 = RARRAY(rb_argv)->len + 1;
}

%typemap(ignore) char **PROG_ARGV {
    int i, n;
    VALUE ary = rb_eval_string("[$0] + ARGV");
    n = RARRAY(ary)->len;
    $1 = (char **)malloc(n + 1);
    for (i = 0; i < n; i++) {
	VALUE v = rb_obj_as_string(RARRAY(ary)->ptr[i]);
	$1[i] = (char *)malloc(RSTRING(v)->len + 1);
	strcpy($1[i], RSTRING(v)->ptr);
    }
}

%typemap(freearg) char **PROG_ARGV {
    int i, n = RARRAY(rb_argv)->len + 1;
    for (i = 0; i < n; i++) free($1[i]);
    free($1);
}

// FILE *
%{
#ifdef __cplusplus
extern "C" {
#endif
#include "rubyio.h"
#ifdef __cplusplus
}
#endif
%}

%typemap(in) FILE *READ {
    OpenFile *of;
    GetOpenFile($input, of);
    rb_io_check_readable(of);
    $1 = GetReadFile(of);
    rb_read_check($1);
}

%typemap(in) FILE *READ_NOCHECK {
    OpenFile *of;
    GetOpenFile($input, of);
    rb_io_check_readable(of);
    $1 = GetReadFile(of);
}

%typemap(in) FILE *WRITE {
    OpenFile *of;
    GetOpenFile($input, of);
    rb_io_check_writable(of);
    $1 = GetWriteFile(of);
}

/* Overloading information */

%typemap(typecheck) double *INPUT = double;
%typemap(typecheck) signed char *INPUT = signed char;
%typemap(typecheck) unsigned char *INPUT = unsigned char;
%typemap(typecheck) unsigned long *INPUT = unsigned long;
%typemap(typecheck) unsigned short *INPUT = unsigned short;
%typemap(typecheck) unsigned int *INPUT = unsigned int;
%typemap(typecheck) long *INPUT = long;
%typemap(typecheck) short *INPUT = short;
%typemap(typecheck) int *INPUT = int;
%typemap(typecheck) float *INPUT = float;

%typemap(typecheck) double &INPUT = double;
%typemap(typecheck) signed char &INPUT = signed char;
%typemap(typecheck) unsigned char &INPUT = unsigned char;
%typemap(typecheck) unsigned long &INPUT = unsigned long;
%typemap(typecheck) unsigned short &INPUT = unsigned short;
%typemap(typecheck) unsigned int &INPUT = unsigned int;
%typemap(typecheck) long &INPUT = long;
%typemap(typecheck) short &INPUT = short;
%typemap(typecheck) int &INPUT = int;
%typemap(typecheck) float &INPUT = float;

%typemap(typecheck) double *INOUT = double;
%typemap(typecheck) signed char *INOUT = signed char;
%typemap(typecheck) unsigned char *INOUT = unsigned char;
%typemap(typecheck) unsigned long *INOUT = unsigned long;
%typemap(typecheck) unsigned short *INOUT = unsigned short;
%typemap(typecheck) unsigned int *INOUT = unsigned int;
%typemap(typecheck) long *INOUT = long;
%typemap(typecheck) short *INOUT = short;
%typemap(typecheck) int *INOUT = int;
%typemap(typecheck) float *INOUT = float;

%typemap(typecheck) double &INOUT = double;
%typemap(typecheck) signed char &INOUT = signed char;
%typemap(typecheck) unsigned char &INOUT = unsigned char;
%typemap(typecheck) unsigned long &INOUT = unsigned long;
%typemap(typecheck) unsigned short &INOUT = unsigned short;
%typemap(typecheck) unsigned int &INOUT = unsigned int;
%typemap(typecheck) long &INOUT = long;
%typemap(typecheck) short &INOUT = short;
%typemap(typecheck) int &INOUT = int;
%typemap(typecheck) float &INOUT = float;


