//
// SWIG Typemap library
// Dave Beazley
// May 5, 1997
//
// Perl5 implementation
//
// This library provides standard typemaps for modifying SWIG's behavior.
// With enough entries in this file, I hope that very few people actually
// ever need to write a typemap.
//

#ifdef AUTODOC
%section "Typemap Library (Perl 5)",info,after,pre,nosort,skip=1,chop_left=3,chop_right=0,chop_top=0,chop_bottom=0
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

%typemap(in) double *INPUT(double temp)
{
  temp = (double) SvNV($input);
  $1 = &temp;
}

%typemap(in) float  *INPUT(float temp)
{
  temp = (float) SvNV($input);
  $1 = &temp;
}

%typemap(in) int            *INPUT(int temp)
{
  temp = (int) SvIV($input);
  $1 = &temp;
}

%typemap(in) short          *INPUT(short temp)
{
  temp = (short) SvIV($input);
  $1 = &temp;
}

%typemap(in) long           *INPUT(long temp)
{
  temp = (long) SvIV($input);
  $1 = &temp;
}
%typemap(in) unsigned int   *INPUT(unsigned int temp)
{
  temp = (unsigned int) SvIV($input);
  $1 = &temp;
}
%typemap(in) unsigned short *INPUT(unsigned short temp)
{
  temp = (unsigned short) SvIV($input);
  $1 = &temp;
}
%typemap(in) unsigned long  *INPUT(unsigned long temp)
{
  temp = (unsigned long) SvIV($input);
  $1 = &temp;
}
%typemap(in) unsigned char  *INPUT(unsigned char temp)
{
  temp = (unsigned char) SvIV($input);
  $1 = &temp;
}
                 
// OUTPUT typemaps.   These typemaps are used for parameters that
// are output only.   The output value is appended to the result as
// a list element.


#ifdef AUTODOC
%subsection "Output Methods"

%text %{
The following methods can be applied to turn a pointer into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned.  In the case of
multiple output values, functions will return a Perl array.

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

The Perl output of the function would be an array containing both
output values. 

%}

#endif

// Force the argument to be ignored.

%typemap(ignore) int            *OUTPUT(int temp),
                       short          *OUTPUT(short temp),
                       long           *OUTPUT(long temp),
                       unsigned int   *OUTPUT(unsigned int temp),
                       unsigned short *OUTPUT(unsigned short temp),
                       unsigned long  *OUTPUT(unsigned long temp),
                       unsigned char  *OUTPUT(unsigned char temp),
                       float          *OUTPUT(float temp),
                       double         *OUTPUT(double temp)
{
  $1 = &temp;
}

%typemap(argout) int            *OUTPUT,
                       short          *OUTPUT,
                       long           *OUTPUT,
                       unsigned int   *OUTPUT,
                       unsigned short *OUTPUT,
                       unsigned long  *OUTPUT,
                       unsigned char  *OUTPUT
{
  if (argvi >= items) {
    EXTEND(sp,1);
  }
  $result = sv_newmortal();
  sv_setiv($result,(IV) *($1));
  argvi++;
}

%typemap(argout) float    *OUTPUT,
                       double   *OUTPUT
{
  if (argvi >= items) {
    EXTEND(sp,1);
  }
  $result = sv_newmortal();
  sv_setnv($result,(double) *($1));
  argvi++;
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
returned in the form of a Tcl list.

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

Unlike C, this mapping does not directly modify the input value.
Rather, the modified input value shows up as the return value of the
function.  Thus, to apply this function to a Perl variable you might
do this :

       $x = neg($x);

%}

#endif

%typemap(in) int *INOUT = int *INPUT;
%typemap(in) short *INOUT = short *INPUT;
%typemap(in) long *INOUT = long *INPUT;
%typemap(in) unsigned *INOUT = unsigned *INPUT;
%typemap(in) unsigned short *INOUT = unsigned short *INPUT;
%typemap(in) unsigned long *INOUT = unsigned long *INPUT;
%typemap(in) unsigned char *INOUT = unsigned char *INPUT;
%typemap(in) float *INOUT = float *INPUT;
%typemap(in) double *INOUT = double *INPUT;

%typemap(argout) int *INOUT = int *OUTPUT;
%typemap(argout) short *INOUT = short *OUTPUT;
%typemap(argout) long *INOUT = long *OUTPUT;
%typemap(argout) unsigned *INOUT = unsigned *OUTPUT;
%typemap(argout) unsigned short *INOUT = unsigned short *OUTPUT;
%typemap(argout) unsigned long *INOUT = unsigned long *OUTPUT;
%typemap(argout) unsigned char *INOUT = unsigned char *OUTPUT;
%typemap(argout) float *INOUT = float *OUTPUT;
%typemap(argout) double *INOUT = double *OUTPUT;

%apply int *INOUT { int *BOTH };
%apply short *INOUT { short *BOTH };
%apply long *INOUT { long *BOTH };
%apply unsigned int *INOUT { unsigned int *BOTH };
%apply unsigned long *INOUT { unsigned long *BOTH };
%apply unsigned short *INOUT { unsigned short *BOTH };
%apply unsigned char *INOUT { unsigned char *BOTH };
%apply float *INOUT { float *BOTH };
%apply double *INOUT { double *BOTH };

// REFERENCE
// Accept Perl references as pointers


#ifdef AUTODOC
%subsection "Reference Methods"

%text %{
The following methods make Perl references work like simple C
pointers.  References can only be used for simple input/output
values, not C arrays however.  It should also be noted that 
REFERENCES are specific to Perl and not supported in other
scripting languages at this time.

         int            *REFERENCE
         short          *REFERENCE
         long           *REFERENCE
         unsigned int   *REFERENCE
         unsigned short *REFERENCE
         unsigned long  *REFERENCE
         unsigned char  *REFERENCE
         float          *REFERENCE
         double         *REFERENCE
         
For example, suppose you were trying to wrap the following function :

        void neg(double *x) {
             *x = -(*x);
        }

You could wrap it with SWIG as follows :

        %include typemaps.i
        void neg(double *REFERENCE);

or you can use the %apply directive :

        %include typemaps.i
        %apply double *REFERENCE { double *x };
        void neg(double *x);

Unlike the INOUT mapping described previous, this approach directly
modifies the value of a Perl reference.  Thus, you could use it
as follows :

       $x = 3;
       neg(\$x);
       print "$x\n";         # Should print out -3.
%}

#endif

%typemap(in) double *REFERENCE (double dvalue)
{
  SV *tempsv;
  if (!SvROK($input)) {
    croak("expected a reference");
  }
  tempsv = SvRV($input);
  if ((!SvNOK(tempsv)) && (!SvIOK(tempsv))) {
	printf("Received %d\n", SvTYPE(tempsv));
	croak("Expected a double reference.");
  }
  dvalue = SvNV(tempsv);
  $1 = &dvalue;
}

%typemap(in) float *REFERENCE (float dvalue)
{
  SV *tempsv;
  if (!SvROK($input)) {
    croak("expected a reference");
  }
  tempsv = SvRV($input);
  if ((!SvNOK(tempsv)) && (!SvIOK(tempsv))) {
    croak("expected a double reference");
  }
  dvalue = (float) SvNV(tempsv);
  $1 = &dvalue;
}

%typemap(in) int *REFERENCE (int dvalue)
{
  SV *tempsv;
  if (!SvROK($input)) {
    croak("expected a reference");
  }
  tempsv = SvRV($input);
  if (!SvIOK(tempsv)) {
    croak("expected a integer reference");
  }
  dvalue = SvIV(tempsv);
  $1 = &dvalue;
}

%typemap(in) short *REFERENCE (short dvalue)
{
  SV *tempsv;
  if (!SvROK($input)) {
    croak("expected a reference");
  }
  tempsv = SvRV($input);
  if (!SvIOK(tempsv)) {
    croak("expected a integer reference");
  }
  dvalue = (short) SvIV(tempsv);
  $1 = &dvalue;
}
%typemap(in) long *REFERENCE (long dvalue)
{
  SV *tempsv;
  if (!SvROK($input)) {
    croak("expected a reference");
  }
  tempsv = SvRV($input);
  if (!SvIOK(tempsv)) {
    croak("expected a integer reference");
  }
  dvalue = (long) SvIV(tempsv);
  $1 = &dvalue;
}
%typemap(in) unsigned int *REFERENCE (unsigned int dvalue)
{
  SV *tempsv;
  if (!SvROK($input)) {
    croak("expected a reference");
  }
  tempsv = SvRV($input);
  if (!SvIOK(tempsv)) {
    croak("expected a integer reference");
  }
  dvalue = (unsigned int) SvIV(tempsv);
  $1 = &dvalue;
}
%typemap(in) unsigned short *REFERENCE (unsigned short dvalue)
{
  SV *tempsv;
  if (!SvROK($input)) {
    croak("expected a reference");
  }
  tempsv = SvRV($input);
  if (!SvIOK(tempsv)) {
    croak("expected a integer reference");
  }
  dvalue = (unsigned short) SvIV(tempsv);
  $1 = &dvalue;
}
%typemap(in) unsigned long *REFERENCE (unsigned long dvalue)
{
  SV *tempsv;
  if (!SvROK($input)) {
    croak("expected a reference");
  }
  tempsv = SvRV($input);
  if (!SvIOK(tempsv)) {
    croak("expected a integer reference");
  }
  dvalue = (unsigned long) SvIV(tempsv);
  $1 = &dvalue;
}

%typemap(argout) double *REFERENCE,
                       float  *REFERENCE
{
  SV *tempsv;
  tempsv = SvRV($arg);
  sv_setnv(tempsv, (double) *$1);
}

%typemap(argout) int            *REFERENCE,
                       short          *REFERENCE,
                       long           *REFERENCE,
                       unsigned int   *REFERENCE,
                       unsigned short *REFERENCE,
                       unsigned long  *REFERENCE
{
  SV *tempsv;
  tempsv = SvRV($input);
  sv_setiv(tempsv, (int) *$1);
}

/* Overloading information */

%typemap(typecheck) double *INPUT = double;
%typemap(typecheck) bool *INPUT = bool;
%typemap(typecheck) signed char *INPUT = signed char;
%typemap(typecheck) unsigned char *INPUT = unsigned char;
%typemap(typecheck) unsigned long *INPUT = unsigned long;
%typemap(typecheck) unsigned short *INPUT = unsigned short;
%typemap(typecheck) unsigned int *INPUT = unsigned int;
%typemap(typecheck) long *INPUT = long;
%typemap(typecheck) short *INPUT = short;
%typemap(typecheck) int *INPUT = int;
%typemap(typecheck) float *INPUT = float;

%typemap(typecheck) double *INOUT = double;
%typemap(typecheck) bool *INOUT = bool;
%typemap(typecheck) signed char *INOUT = signed char;
%typemap(typecheck) unsigned char *INOUT = unsigned char;
%typemap(typecheck) unsigned long *INOUT = unsigned long;
%typemap(typecheck) unsigned short *INOUT = unsigned short;
%typemap(typecheck) unsigned int *INOUT = unsigned int;
%typemap(typecheck) long *INOUT = long;
%typemap(typecheck) short *INOUT = short;
%typemap(typecheck) int *INOUT = int;
%typemap(typecheck) float *INOUT = float;

