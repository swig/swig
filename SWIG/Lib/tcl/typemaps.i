/* -----------------------------------------------------------------------------
 * typemaps.i
 *
 *      Swig typemap library for Tcl8.  This file contains various sorts
 *      of typemaps for modifying Swig's code generation.
 *
 * Author: David Beazley (beazley@cs.uchicago.edu)
 *
 * ----------------------------------------------------------------------------- */

#ifdef AUTODOC
%section "Typemap Library (Tcl)",info,after,pre,nosort,skip=1,chop_left=3,chop_right=0,chop_top=0,chop_bottom=0
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

%typemap(tcl8,in) double *INPUT(double temp)
{
  if (Tcl_GetDoubleFromObj(interp,$input,&temp) == TCL_ERROR) {
    return TCL_ERROR;
  }
  $1 = &temp;
}

%typemap(tcl8,in) float *INPUT(double dvalue, float  temp) 
{
  if (Tcl_GetDoubleFromObj(interp,$input,&dvalue) == TCL_ERROR) {
    return TCL_ERROR;
  }
  temp = (float) dvalue;
  $1 = &temp;
}

%typemap(tcl8,in) int  *INPUT(int temp)
{
  if (Tcl_GetIntFromObj(interp,$input,&temp) == TCL_ERROR) {
    return TCL_ERROR;
  }
  $1 = &temp;
}

%typemap(tcl8,in) short *INPUT(int ivalue, short temp)
{
  if (Tcl_GetIntFromObj(interp,$input,&ivalue) == TCL_ERROR) {
    return TCL_ERROR;
  }
  temp = (short) ivalue;
  $1 = &temp;
}

%typemap(tcl8,in) long *INPUT(int ivalue, long temp)
{
  if (Tcl_GetIntFromObj(interp,$input,&ivalue) == TCL_ERROR) {
    return TCL_ERROR;
  }
  temp = (long) ivalue;
  $1 = &temp;
}

%typemap(tcl8,in) unsigned int  *INPUT(int ivalue, unsigned int temp)
{
  if (Tcl_GetIntFromObj(interp,$input,&ivalue) == TCL_ERROR) {
    return TCL_ERROR;
  }
  temp = (unsigned int) ivalue;
  $1 = &temp;
}

%typemap(tcl8,in) unsigned short *INPUT(int ivalue, unsigned short temp)
{
  if (Tcl_GetIntFromObj(interp,$input,&ivalue) == TCL_ERROR) {
    return TCL_ERROR;
  }
  temp = (unsigned short) ivalue;
  $1 = &temp;
}

%typemap(tcl8,in) unsigned long *INPUT(int ivalue, unsigned long temp)
{
  if (Tcl_GetIntFromObj(interp,$input,&ivalue) == TCL_ERROR) {
    return TCL_ERROR;
  }
  temp = (unsigned long) ivalue;
  $1 = &temp;
}

%typemap(tcl8,in) unsigned char *INPUT(int ivalue, unsigned char temp)
{
  if (Tcl_GetIntFromObj(interp,$input,&ivalue) == TCL_ERROR) {
    return TCL_ERROR;
  }
  temp = (unsigned char) ivalue;
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
multiple output values, they are returned in the form of a Tcl list.

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

The Tcl output of the function would be a list containing both
output values. 

%}

#endif


%typemap(tcl8,ignore) int            *OUTPUT(int temp),
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

%typemap(tcl8,argout) int     *OUTPUT,
                     short   *OUTPUT,
                     long    *OUTPUT,
                     unsigned int   *OUTPUT,
                     unsigned short *OUTPUT,
                     unsigned long  *OUTPUT,
                     unsigned char  *OUTPUT
{
  Tcl_Obj *o;
  o = Tcl_NewIntObj((int) *($1));
  Tcl_ListObjAppendElement(interp,Tcl_GetObjResult(interp),o);
}

%typemap(tcl8,argout) float    *OUTPUT,
                     double   *OUTPUT
{
  Tcl_Obj *o;
  o = Tcl_NewDoubleObj((double) *($1));
  Tcl_ListObjAppendElement(interp,Tcl_GetObjResult(interp),o);
}

// BOTH
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

Unlike C, this mapping does not directly modify the input value (since
this makes no sense in Tcl).  Rather, the modified input value shows
up as the return value of the function.  Thus, to apply this function
to a Tcl variable you might do this :

       set x [neg $x]

%}

#endif


%typemap(tcl8,in) int *INOUT = int *INPUT;
%typemap(tcl8,in) short *INOUT = short *INPUT;
%typemap(tcl8,in) long *INOUT = long *INPUT;
%typemap(tcl8,in) unsigned int *INOUT = unsigned int *INPUT;
%typemap(tcl8,in) unsigned short *INOUT = unsigned short *INPUT;
%typemap(tcl8,in) unsigned long *INOUT = unsigned long *INPUT;
%typemap(tcl8,in) unsigned char *INOUT = unsigned char *INPUT;
%typemap(tcl8,in) float *INOUT = float *INPUT;
%typemap(tcl8,in) double *INOUT = double *INPUT;

%typemap(tcl8,argout) int *INOUT = int *OUTPUT;
%typemap(tcl8,argout) short *INOUT = short *OUTPUT;
%typemap(tcl8,argout) long *INOUT = long *OUTPUT;
%typemap(tcl8,argout) unsigned int *INOUT = unsigned int *OUTPUT;
%typemap(tcl8,argout) unsigned short *INOUT = unsigned short *OUTPUT;
%typemap(tcl8,argout) unsigned long *INOUT = unsigned long *OUTPUT;
%typemap(tcl8,argout) unsigned char *INOUT = unsigned char *OUTPUT;
%typemap(tcl8,argout) float *INOUT = float *OUTPUT;
%typemap(tcl8,argout) double *INOUT = double *OUTPUT;

%apply int *INOUT { int *BOTH };
%apply short *INOUT { short *BOTH };
%apply long *INOUT { long *BOTH };
%apply unsigned int *INOUT { unsigned int *BOTH };
%apply unsigned long *INOUT { unsigned long *BOTH };
%apply unsigned short *INOUT { unsigned short *BOTH };
%apply unsigned char *INOUT { unsigned char *BOTH };
%apply float *INOUT { float *BOTH };
%apply double *INOUT { double *BOTH };

// --------------------------------------------------------------------
// Special types
// --------------------------------------------------------------------

// If interp * appears as a function argument, we ignore it and get
// it from the wrapper function.

#ifdef AUTODOC
%subsection "Special Methods"

%text %{
The typemaps.i library also provides the following mappings :

Tcl_Interp *interp

      Passes the current Tcl_Interp value directly to a C function.
      This can be used to work with existing wrapper functions or
      if you just need the interp value for some reason.  When used,
      the 'interp' parameter becomes hidden in the Tcl interface--that
      is, you don't specify it explicitly. SWIG fills in its value
      automatically.

int Tcl_Result

      Makes the integer return code of a function the return value 
      of a SWIG generated wrapper function.  For example :

            int foo() {
                  ... do stuff ...
                  return TCL_OK;
            }      

      could be wrapped as follows :

            %include typemaps.i
            %apply int Tcl_Result { int foo };
            int foo();
 
%}

#endif

%typemap(tcl8,ignore) Tcl_Interp *interp {
  $1 = interp;
}

// If return code is a Tcl_Result, simply pass it on

%typemap(tcl8,out) int Tcl_Result {
  return $1;
}



  
  
  


