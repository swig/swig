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

%}
#endif

%typemap(in) double *INPUT(double temp)
{
  temp = PyFloat_AsDouble($input);
  $1 = &temp;
}

%typemap(in) float  *INPUT(float temp)
{
  temp = (float) PyFloat_AsDouble($input);
  $1 = &temp;
}

%typemap(in) int            *INPUT(int temp)
{
  temp = (int) PyInt_AsLong($input);
  $1 = &temp;
}

%typemap(in) short          *INPUT(short temp)
{
  temp = (short) PyInt_AsLong($input);
  $1 = &temp;
}

%typemap(in) long           *INPUT(long temp)
{
  temp = (long) PyInt_AsLong($input);
  $1 = &temp;
}

%typemap(in) unsigned int   *INPUT(unsigned int temp)
{
  temp = (unsigned int) PyInt_AsLong($input);
  $1 = &temp;
}

%typemap(in) unsigned short *INPUT(unsigned short temp)
{
  temp = (unsigned short) PyInt_AsLong($input);
  $1 = &temp;
}

%typemap(in) unsigned long  *INPUT(unsigned long temp)
{
  temp = (unsigned long) PyInt_AsLong($input);
  $1 = &temp;
}

%typemap(in) unsigned char  *INPUT(unsigned char temp)
{
  temp = (unsigned char) PyInt_AsLong($input);
  $1 = &temp;
}

%typemap(in) signed char  *INPUT(signed char temp)
{
  temp = (unsigned char) PyInt_AsLong($input);
  $1 = &temp;
}

%typemap(in) bool *INPUT(bool temp) 
{
  temp = (bool) PyInt_AsLong($input);
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
multiple output values, they are returned in the form of a Python tuple.

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
         
A Python List can also be returned by using L_OUTPUT instead of OUTPUT.

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
%}
#endif

// Helper function for List output

%{
static PyObject* l_output_helper(PyObject* target, PyObject* o) {
    PyObject*   o2;
    if (!target) {                   
        target = o;
    } else if (target == Py_None) {  
        Py_DECREF(Py_None);
        target = o;
    } else {                         
        if (!PyList_Check(target)) {
            o2 = target;
            target = PyList_New(0);
            PyList_Append(target, o2);
	    Py_XDECREF(o2);
        }
        PyList_Append(target,o);
	Py_XDECREF(o);
    }
    return target;
}
%}

// Force the argument to be ignored.

%typemap(ignore) int            *L_OUTPUT(int temp),
                        short          *L_OUTPUT(short temp),
                        long           *L_OUTPUT(long temp),
                        unsigned int   *L_OUTPUT(unsigned int temp),
                        unsigned short *L_OUTPUT(unsigned short temp),
                        unsigned long  *L_OUTPUT(unsigned long temp),
                        unsigned char  *L_OUTPUT(unsigned char temp),
                        signed char    *L_OUTPUT(signed char temp),  
	                bool           *L_OUTPUT(bool temp),
                        float          *L_OUTPUT(float temp),
                        double         *L_OUTPUT(double temp)
                       
{
  $1 = &temp;
}

%typemap(argout) int            *L_OUTPUT,
                        short          *L_OUTPUT,
                        long           *L_OUTPUT,
                        unsigned int   *L_OUTPUT,
                        unsigned short *L_OUTPUT,
                        unsigned long  *L_OUTPUT,
                        unsigned char  *L_OUTPUT,
                        signed char    *L_OUTPUT,
                        bool           *L_OUTPUT
{
    PyObject *o;
    o = PyInt_FromLong((long) (*$1));
    $result = l_output_helper($result,o);
}

%typemap(argout) float    *L_OUTPUT,
                        double   *L_OUTPUT
{
    PyObject *o;
    o = PyFloat_FromDouble((double) (*$1));
    $result = l_output_helper($result,o);
}

// These typemaps contributed by Robin Dunn
//----------------------------------------------------------------------
//
// T_OUTPUT typemap (and helper function) to return multiple argouts as
// a tuple instead of a list.
//
// Author: Robin Dunn
//----------------------------------------------------------------------

%{
static PyObject* t_output_helper(PyObject* target, PyObject* o) {
    PyObject*   o2;
    PyObject*   o3;

    if (!target) {                   
        target = o;
    } else if (target == Py_None) {  
        Py_DECREF(Py_None);
        target = o;
    } else {                         
        if (!PyTuple_Check(target)) {
            o2 = target;
            target = PyTuple_New(1);
            PyTuple_SetItem(target, 0, o2);
        }
        o3 = PyTuple_New(1);            
        PyTuple_SetItem(o3, 0, o);      

        o2 = target;
        target = PySequence_Concat(o2, o3); 
        Py_DECREF(o2);                      
        Py_DECREF(o3);
    }
    return target;
}
%}

// Force the argument to be ignored.
%typemap(ignore) int            *T_OUTPUT(int temp),
                        short          *T_OUTPUT(short temp),
                        long           *T_OUTPUT(long temp),
                        unsigned int   *T_OUTPUT(unsigned int temp),
                        unsigned short *T_OUTPUT(unsigned short temp),
                        unsigned long  *T_OUTPUT(unsigned long temp),
                        signed char    *T_OUTPUT(signed char temp),
                        unsigned char  *T_OUTPUT(unsigned char temp),
                        bool           *T_OUTPUT(bool temp),
                        float          *T_OUTPUT(float temp),
                        double         *T_OUTPUT(double temp)
{
  $1 = &temp;
}

%typemap(argout) int            *T_OUTPUT,
                        short          *T_OUTPUT,
                        long           *T_OUTPUT,
                        unsigned int   *T_OUTPUT,
                        unsigned short *T_OUTPUT,
                        unsigned long  *T_OUTPUT,
                        unsigned char  *T_OUTPUT,
                        signed char    *T_OUTPUT,
                        bool           *T_OUTPUT
{
    PyObject *o;
    o = PyInt_FromLong((long) (*$1));
    $result = t_output_helper($result, o);
}

%typemap(argout) float    *T_OUTPUT,
                        double   *T_OUTPUT
{
    PyObject *o;
    o = PyFloat_FromDouble((double) (*$1));
    $result = t_output_helper($result, o);
}

// Set the default output typemap

#ifdef OUTPUT_LIST
%typemap(ignore) int                *OUTPUT = int   *L_OUTPUT;
%typemap(ignore) short              *OUTPUT = short *L_OUTPUT;
%typemap(ignore) long               *OUTPUT = long  *L_OUTPUT;
%typemap(ignore) unsigned           *OUTPUT = unsigned *L_OUTPUT;
%typemap(ignore) unsigned short     *OUTPUT = unsigned short *L_OUTPUT;
%typemap(ignore) unsigned long      *OUTPUT = unsigned long  *L_OUTPUT;
%typemap(ignore) unsigned char      *OUTPUT = unsigned char  *L_OUTPUT;
%typemap(ignore) signed char        *OUTPUT = signed char    *L_OUTPUT;
%typemap(ignore) bool               *OUTPUT = bool           *L_OUTPUT;
%typemap(ignore) double             *OUTPUT = double         *L_OUTPUT;
%typemap(ignore) float              *OUTPUT = float          *L_OUTPUT;

%typemap(argout) int                *OUTPUT = int   *L_OUTPUT;
%typemap(argout) short              *OUTPUT = short *L_OUTPUT;
%typemap(argout) long               *OUTPUT = long  *L_OUTPUT;
%typemap(argout) unsigned           *OUTPUT = unsigned *L_OUTPUT;
%typemap(argout) unsigned short     *OUTPUT = unsigned short *L_OUTPUT;
%typemap(argout) unsigned long      *OUTPUT = unsigned long  *L_OUTPUT;
%typemap(argout) unsigned char      *OUTPUT = unsigned char  *L_OUTPUT;
%typemap(argout) signed char        *OUTPUT = signed char    *L_OUTPUT;
%typemap(argout) bool               *OUTPUT = bool           *L_OUTPUT;
%typemap(argout) double             *OUTPUT = double         *L_OUTPUT;
%typemap(argout) float              *OUTPUT = float          *L_OUTPUT;
#else
%typemap(ignore) int                *OUTPUT = int   *T_OUTPUT;
%typemap(ignore) short              *OUTPUT = short *T_OUTPUT;
%typemap(ignore) long               *OUTPUT = long  *T_OUTPUT;
%typemap(ignore) unsigned           *OUTPUT = unsigned *T_OUTPUT;
%typemap(ignore) unsigned short     *OUTPUT = unsigned short *T_OUTPUT;
%typemap(ignore) unsigned long      *OUTPUT = unsigned long  *T_OUTPUT;
%typemap(ignore) unsigned char      *OUTPUT = unsigned char  *T_OUTPUT;
%typemap(ignore) signed char        *OUTPUT = signed char    *T_OUTPUT;
%typemap(ignore) bool               *OUTPUT = bool           *T_OUTPUT;
%typemap(ignore) double             *OUTPUT = double         *T_OUTPUT;
%typemap(ignore) float              *OUTPUT = float          *T_OUTPUT;

%typemap(argout) int                *OUTPUT = int   *T_OUTPUT;
%typemap(argout) short              *OUTPUT = short *T_OUTPUT;
%typemap(argout) long               *OUTPUT = long  *T_OUTPUT;
%typemap(argout) unsigned           *OUTPUT = unsigned *T_OUTPUT;
%typemap(argout) unsigned short     *OUTPUT = unsigned short *T_OUTPUT;
%typemap(argout) unsigned long      *OUTPUT = unsigned long  *T_OUTPUT;
%typemap(argout) unsigned char      *OUTPUT = unsigned char  *T_OUTPUT;
%typemap(argout) signed char        *OUTPUT = signed char    *T_OUTPUT;
%typemap(argout) bool               *OUTPUT = bool           *T_OUTPUT;
%typemap(argout) double             *OUTPUT = double         *T_OUTPUT;
%typemap(argout) float              *OUTPUT = float          *T_OUTPUT;
#endif

// INOUT
// Mappings for an argument that is both an input and output
// parameter


#ifdef AUTODOC
%subsection "Input/Output Methods"

%text %{
The following methods can be applied to make a function parameter both
an input and output value.  This combines the behavior of both the
"INPUT" and "OUTPUT" methods described earlier.  Output values are
returned in the form of a Python tuple.  To return a Python list,
using L_INOUT instead.

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
this makes no sense in Python).  Rather, the modified input value shows
up as the return value of the function.  Thus, to apply this function
to a Python variable you might do this :

       x = neg(x)

Note : previous versions of SWIG used the symbol 'BOTH' to mark
input/output arguments.   This is still supported, but will be slowly
phased out in future releases.
%}

#endif

%typemap(in) int *INOUT = int *INPUT;
%typemap(in) short *INOUT = short *INPUT;
%typemap(in) long *INOUT = long *INPUT;
%typemap(in) unsigned *INOUT = unsigned *INPUT;
%typemap(in) unsigned short *INOUT = unsigned short *INPUT;
%typemap(in) unsigned long *INOUT = unsigned long *INPUT;
%typemap(in) unsigned char *INOUT = unsigned char *INPUT;
%typemap(in) bool *INOUT = bool *INPUT;
%typemap(in) float *INOUT = float *INPUT;
%typemap(in) double *INOUT = double *INPUT;

%typemap(argout) int *INOUT = int *OUTPUT;
%typemap(argout) short *INOUT = short *OUTPUT;
%typemap(argout) long *INOUT = long *OUTPUT;
%typemap(argout) unsigned *INOUT = unsigned *OUTPUT;
%typemap(argout) unsigned short *INOUT = unsigned short *OUTPUT;
%typemap(argout) unsigned long *INOUT = unsigned long *OUTPUT;
%typemap(argout) unsigned char *INOUT = unsigned char *OUTPUT;
%typemap(argout) bool *INOUT = bool *OUTPUT;
%typemap(argout) float *INOUT = float *OUTPUT;
%typemap(argout) double *INOUT = double *OUTPUT;

%typemap(in) int *T_INOUT = int *INPUT;
%typemap(in) short *T_INOUT = short *INPUT;
%typemap(in) long *T_INOUT = long *INPUT;
%typemap(in) unsigned *T_INOUT = unsigned *INPUT;
%typemap(in) unsigned short *T_INOUT = unsigned short *INPUT;
%typemap(in) unsigned long *T_INOUT = unsigned long *INPUT;
%typemap(in) unsigned char *T_INOUT = unsigned char *INPUT;
%typemap(in) bool *T_INOUT = bool *INPUT;
%typemap(in) float *T_INOUT = float *INPUT;
%typemap(in) double *T_INOUT = double *INPUT;

%typemap(argout) int *T_INOUT = int *T_OUTPUT;
%typemap(argout) short *T_INOUT = short *T_OUTPUT;
%typemap(argout) long *T_INOUT = long *T_OUTPUT;
%typemap(argout) unsigned *T_INOUT = unsigned *T_OUTPUT;
%typemap(argout) unsigned short *T_INOUT = unsigned short *T_OUTPUT;
%typemap(argout) unsigned long *T_INOUT = unsigned long *T_OUTPUT;
%typemap(argout) unsigned char *T_INOUT = unsigned char *T_OUTPUT;
%typemap(argout) bool *T_INOUT = bool *T_OUTPUT;
%typemap(argout) float *T_INOUT = float *T_OUTPUT;
%typemap(argout) double *T_INOUT = double *T_OUTPUT;

%typemap(in) int *L_INOUT = int *INPUT;
%typemap(in) short *L_INOUT = short *INPUT;
%typemap(in) long *L_INOUT = long *INPUT;
%typemap(in) unsigned *L_INOUT = unsigned *INPUT;
%typemap(in) unsigned short *L_INOUT = unsigned short *INPUT;
%typemap(in) unsigned long *L_INOUT = unsigned long *INPUT;
%typemap(in) unsigned char *L_INOUT = unsigned char *INPUT;
%typemap(in) bool *L_INOUT = bool *INPUT;
%typemap(in) float *L_INOUT = float *INPUT;
%typemap(in) double *L_INOUT = double *INPUT;

%typemap(argout) int *L_INOUT = int *L_OUTPUT;
%typemap(argout) short *L_INOUT = short *L_OUTPUT;
%typemap(argout) long *L_INOUT = long *L_OUTPUT;
%typemap(argout) unsigned *L_INOUT = unsigned *L_OUTPUT;
%typemap(argout) unsigned short *L_INOUT = unsigned short *L_OUTPUT;
%typemap(argout) unsigned long *L_INOUT = unsigned long *L_OUTPUT;
%typemap(argout) unsigned char *L_INOUT = unsigned char *L_OUTPUT;
%typemap(argout) bool *L_INOUT = bool *L_OUTPUT;
%typemap(argout) float *L_INOUT = float *L_OUTPUT;
%typemap(argout) double *L_INOUT = double *L_OUTPUT;

// Backwards compatibility

%apply int *INOUT { int *BOTH };
%apply short *INOUT { short *BOTH };
%apply long *INOUT { long *BOTH };
%apply unsigned int *INOUT { unsigned int *BOTH };
%apply unsigned long *INOUT { unsigned long *BOTH };
%apply unsigned short *INOUT { unsigned short *BOTH };
%apply unsigned char *INOUT { unsigned char *BOTH };
%apply bool *INOUT { bool *BOTH };
%apply float *INOUT { float *BOTH };
%apply double *INOUT { double *BOTH };

%apply int *T_INOUT { int *T_BOTH };
%apply short *T_INOUT { short *T_BOTH };
%apply long *T_INOUT { long *T_BOTH };
%apply unsigned int *T_INOUT { unsigned int *T_BOTH };
%apply unsigned long *T_INOUT { unsigned long *T_BOTH };
%apply unsigned short *T_INOUT { unsigned short *T_BOTH };
%apply unsigned char *T_INOUT { unsigned char *T_BOTH };
%apply bool *T_INOUT { bool *T_BOTH };
%apply float *T_INOUT { float *T_BOTH };
%apply double *T_INOUT { double *T_BOTH };


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





