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

#ifdef AUTODOC
%section "Typemap Library (Ruby)",info,after,pre,nosort,skip=1,chop_left=3,chop_right=0,chop_top=0,chop_bottom=0
%text %{
%include typemaps.i

The SWIG typemap library provides a language independent mechanism for
supporting output arguments, input values, and other C function
calling mechanisms.  The primary use of the library is to provide a
better interface to certain C function--especially those involving
pointers.
%}

#endif

// ------------------------------------------------------------------------
// Pointer handling
//
// These mappings provide support for input/output arguments and common
// uses for C/C++ pointers.
// ------------------------------------------------------------------------

// INPUT typemaps.
// These remap a C pointer to be an "INPUT" value which is passed by value
// instead of reference.


#ifdef AUTODOC
%subsection "Input Methods"

%text %{
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

%}
#endif

%typemap(ruby,in) double *INPUT(double temp)
{
  temp = NUM2DBL($source);
  $target = &temp;
}

%typemap(ruby,in) float  *INPUT(float temp)
{
  temp = (float) NUM2DBL($source);
  $target = &temp;
}

%typemap(ruby,in) int            *INPUT(int temp)
{
  temp = NUM2INT($source);
  $target = &temp;
}

%typemap(ruby,in) short          *INPUT(short temp)
{
  temp = NUM2SHRT($source);
  $target = &temp;
}

%typemap(ruby,in) long           *INPUT(long temp)
{
  temp = NUM2LONG($source);
  $target = &temp;
}
%typemap(ruby,in) unsigned int   *INPUT(unsigned int temp)
{
  temp = NUM2UINT($source);
  $target = &temp;
}
%typemap(ruby,in) unsigned short *INPUT(unsigned short temp)
{
  temp = NUM2USHRT($source);
  $target = &temp;
}
%typemap(ruby,in) unsigned long  *INPUT(unsigned long temp)
{
  temp = NUM2ULONG($source);
  $target = &temp;
}
%typemap(ruby,in) unsigned char  *INPUT(unsigned char temp)
{
  temp = (unsigned char)NUM2UINT($source);
  $target = &temp;
}

%typemap(ruby,in) signed char  *INPUT(signed char temp)
{
  temp = (signed char)NUM2INT($source);
  $target = &temp;
}
                 
// OUTPUT typemaps.   These typemaps are used for parameters that
// are output only.   The output value is appended to the result as
// a array element.

#ifdef AUTODOC
%subsection "Output Methods"

%text %{
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
%}
#endif

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

%typemap(ruby,ignore) int            *OUTPUT(int temp),
                      short          *OUTPUT(short temp),
                      long           *OUTPUT(long temp),
                      unsigned int   *OUTPUT(unsigned int temp),
                      unsigned short *OUTPUT(unsigned short temp),
                      unsigned long  *OUTPUT(unsigned long temp),
                      unsigned char  *OUTPUT(unsigned char temp),
                      signed char    *OUTPUT(signed char temp),  
                      float          *OUTPUT(float temp),
                      double         *OUTPUT(double temp)
{
    $target = &temp;
}

%typemap(ruby,argout) int            *OUTPUT,
                      short          *OUTPUT,
                      long           *OUTPUT,
                      signed char    *OUTPUT
{
    $target = output_helper($target, INT2NUM(*$source));
}

%typemap(ruby,argout) unsigned int   *OUTPUT,
                      unsigned short *OUTPUT,
                      unsigned long  *OUTPUT,
                      unsigned char  *OUTPUT
{
    $target = output_helper($target, UINT2NUM(*$source));
}

%typemap(ruby,argout) float    *OUTPUT,
                      double   *OUTPUT
{
    $target = output_helper($target, rb_float_new(*$source));
}

// INOUT
// Mappings for an argument that is both an input and output
// parameter


#ifdef AUTODOC
%subsection "Input/Output Methods"

%text %{
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
%}

#endif

%typemap(ruby,in) int *INOUT = int *INPUT;
%typemap(ruby,in) short *INOUT = short *INPUT;
%typemap(ruby,in) long *INOUT = long *INPUT;
%typemap(ruby,in) unsigned *INOUT = unsigned *INPUT;
%typemap(ruby,in) unsigned short *INOUT = unsigned short *INPUT;
%typemap(ruby,in) unsigned long *INOUT = unsigned long *INPUT;
%typemap(ruby,in) unsigned char *INOUT = unsigned char *INPUT;
%typemap(ruby,in) float *INOUT = float *INPUT;
%typemap(ruby,in) double *INOUT = double *INPUT;

%typemap(ruby,argout) int *INOUT = int *OUTPUT;
%typemap(ruby,argout) short *INOUT = short *OUTPUT;
%typemap(ruby,argout) long *INOUT = long *OUTPUT;
%typemap(ruby,argout) unsigned *INOUT = unsigned *OUTPUT;
%typemap(ruby,argout) unsigned short *INOUT = unsigned short *OUTPUT;
%typemap(ruby,argout) unsigned long *INOUT = unsigned long *OUTPUT;
%typemap(ruby,argout) unsigned char *INOUT = unsigned char *OUTPUT;
%typemap(ruby,argout) float *INOUT = float *OUTPUT;
%typemap(ruby,argout) double *INOUT = double *OUTPUT;

// Backwards compatibility

%typemap(ruby,in) int *BOTH = int *INOUT;
%typemap(ruby,in) short *BOTH = short *INOUT;
%typemap(ruby,in) long *BOTH = long *INOUT;
%typemap(ruby,in) unsigned *BOTH = unsigned *INOUT;
%typemap(ruby,in) unsigned short *BOTH = unsigned short *INOUT;
%typemap(ruby,in) unsigned long *BOTH = unsigned long *INOUT;
%typemap(ruby,in) unsigned char *BOTH = unsigned char *INOUT;
%typemap(ruby,in) float *BOTH = float *INOUT;
%typemap(ruby,in) double *BOTH = double *INOUT;

%typemap(ruby,argout) int *BOTH = int *INOUT;
%typemap(ruby,argout) short *BOTH = short *INOUT;
%typemap(ruby,argout) long *BOTH = long *INOUT;
%typemap(ruby,argout) unsigned *BOTH = unsigned *INOUT;
%typemap(ruby,argout) unsigned short *BOTH = unsigned short *INOUT;
%typemap(ruby,argout) unsigned long *BOTH = unsigned long *INOUT;
%typemap(ruby,argout) unsigned char *BOTH = unsigned char *INOUT;
%typemap(ruby,argout) float *BOTH = float *INOUT;
%typemap(ruby,argout) double *BOTH = double *INOUT;

// --------------------------------------------------------------------
// OUTPUT typemaps for user defined type.
//
// --------------------------------------------------------------------

#ifdef AUTODOC
%subsection "Output Methods for User-defined types"

%text %{
The following method can be applied to turn a pointer to
user-defined type returned through function aruguments into
an output value.

         User **OUTPUT
         
You can use the %apply directive :

        %include typemaps.i
        %apply User **OUTPUT { Foo **OUTPUT };
        int foo_func(Foo **OUTPUT);

%}
#endif

%typemap(ruby,ignore) User **OUTPUT(void *temp)
{
  $target = ($type)&temp;
}
%typemap(ruby,argout) User **OUTPUT
{
  $target = output_helper($target, Wrap_$basetype(*$source));
}


// --------------------------------------------------------------------
// Special types
//
// --------------------------------------------------------------------

#ifdef AUTODOC
%subsection "Special Methods"

%text %{
The typemaps.i library also provides the following mappings :

struct timeval *
time_t

    Ruby has builtin class Time.  INPUT/OUPUT typemap for timeval and
    time_t is provided.

int PROG_ARGC
char **PROG_ARGV

    Some C function receive argc and argv from C main function.
    This typemap provides ignore typemap which pass Ruby ARGV contents
    as argc and argv to C function.
%}

#endif


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

%typemap(ruby,in) struct timeval *INPUT (struct timeval temp)
{
    if (NIL_P($source))
	$target = NULL;
    else {
	temp = rb_time_timeval($source);
	$target = &temp;
    }
}

%typemap(ruby,ignore) struct timeval *OUTPUT(struct timeval temp)
{
    $target = &temp;
}

%typemap(ruby,argout) struct timeval *OUTPUT
{
    $target = rb_time_new($source->tv_sec, $source->tv_usec);
}

%typemap(ruby,out) struct timeval *
{
    $target = rb_time_new($source->tv_sec, $source->tv_usec);
}

%typemap(ruby,out) struct timespec *
{
    $target = rb_time_new($source->tv_sec, $source->tv_nsec / 1000);
}

// time_t
%typemap(ruby,in) time_t
{
    if (NIL_P($source))
	$target = (time_t)-1;
    else
	$target = NUM2LONG(rb_funcall($source, rb_intern("tv_sec"), 0));
}

%typemap(ruby,out) time_t
{
    $target = rb_time_new($source, 0);
}

// argc and argv
%typemap(ruby,ignore) int PROG_ARGC {
    $target = RARRAY(rb_argv)->len + 1;
}

%typemap(ruby,ignore) char **PROG_ARGV {
    int i, n;
    VALUE ary = rb_eval_string("[$0] + ARGV");
    n = RARRAY(ary)->len;
    $target = (char **)malloc(n + 1);
    for (i = 0; i < n; i++) {
	VALUE v = rb_obj_as_string(RARRAY(ary)->ptr[i]);
	$target[i] = (char *)malloc(RSTRING(v)->len + 1);
	strcpy($target[i], RSTRING(v)->ptr);
    }
}

%typemap(ruby,freearg) char **PROG_ARGV {
    int i, n = RARRAY(rb_argv)->len + 1;
    for (i = 0; i < n; i++) free($source[i]);
    free($source);
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
%typemap(ruby,in) FILE *READ {
    OpenFile *of;
    Check_Type($source, T_FILE);
    GetOpenFile($source, of);
    rb_io_check_readable(of);
    $target = GetReadFile(of);
    rb_read_check($target);
}
%typemap(ruby,in) FILE *READ_NOCHECK {
    OpenFile *of;
    Check_Type($source, T_FILE);
    GetOpenFile($source, of);
    rb_io_check_readable(of);
    $target = GetReadFile(of);
}
%typemap(ruby,in) FILE *WRITE {
    OpenFile *of;
    Check_Type($source, T_FILE);
    GetOpenFile($source, of);
    rb_io_check_writable(of);
    $target = GetWriteFile(of);
}
