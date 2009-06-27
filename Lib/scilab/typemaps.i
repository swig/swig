/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
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

%typemap(in) signed char *INPUT (int *piAddrVar, int iRows, int iCols, signed char temp),
	     unsigned char *INPUT (int *piAddrVar, int iRows, int iCols, unsigned char temp),
	     short *INPUT (int *piAddrVar, int iRows, int iCols, short temp),
	     unsigned short *INPUT (int *piAddrVar, int iRows, int iCols, unsigned short temp),
	     int *INPUT (int *piAddrVar, int iRows, int iCols, int temp),
	     unsigned int *INPUT (int *piAddrVar, int iRows, int iCols, unsigned int temp),
	     long *INPUT (int *piAddrVar, int iRows, int iCols, long temp),
	     unsigned long *INPUT (int *piAddrVar, int iRows, int iCols, unsigned long temp),
	     float *INPUT (int *piAddrVar, int iRows, int iCols, float temp),
	     double *INPUT (int *piAddrVar, int iRows, int iCols, double temp) {
  double* _piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  temp=($*1_ltype)*_piData;
  $1=&temp;
}
#undef INPUT_TYPEMAP
                 
// OUTPUT typemaps.   These typemaps are used for parameters that
// are output only.   The output value is appended to the result as
// a list element.

/*
The following methods can be applied to turn a pointer into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned.  In the case of
multiple output values, functions will return a Perl array.

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

The Perl output of the function would be an array containing both
output values. 

*/

// Force the argument to be ignored.

%typemap(in,numinputs=0) signed char *OUTPUT (signed temp),
	     unsigned char *OUTPUT (unsigned temp),
	     short *OUTPUT (short temp),
	     unsigned short *OUTPUT (unsigned short temp),
	     int *OUTPUT (int temp),
	     unsigned int *OUTPUT (unsigned int temp),
	     long *OUTPUT (long temp),
	     unsigned long *OUTPUT (unsigned long temp),
	     float *OUTPUT (float temp),
	     double *OUTPUT (double temp) {
  $1=($1_ltype)&temp;
}

%typemap(argout) signed char *OUTPUT(int iRowsOut,int iColsOut,int* _piAddress) {
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger8(iVarOut, iRowsOut, iColsOut, &temp$argnum, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
  iOutNum++;
  iVarOut++;
}

%typemap(argout) short *OUTPUT(int iRowsOut,int iColsOut,int* _piAddress),
              unsigned char *OUTPUT(int iRowsOut,int iColsOut,int* _piAddress) {
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger16(iVarOut, iRowsOut, iColsOut, &temp$argnum, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
  iOutNum++;
  iVarOut++;
}

%typemap(argout) int *OUTPUT(int iRowsOut,int iColsOut,int* _piAddress),
              unsigned int *OUTPUT(int iRowsOut,int iColsOut,int* _piAddress),
              unsigned short *OUTPUT(int iRowsOut,int iColsOut,int* _piAddress),
              unsigned long *OUTPUT(int iRowsOut,int iColsOut,int* _piAddress),
              long *OUTPUT(int iRowsOut,int iColsOut,int* _piAddress) {
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, &temp$argnum, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
  iOutNum++;
  iVarOut++;
}


%typemap(argout) double *OUTPUT(int iRowsOut,int iColsOut),
              float *OUTPUT(int iRowsOut,int iColsOut) {
  double temp;
  temp=(double)(*$result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, &temp$argnum);
  LhsVar(iOutNum)=iVarOut;
  iOutNum++;
  iVarOut++;
}


// INOUT
// Mappings for an argument that is both an input and output
// parameter

/*
The following methods can be applied to make a function parameter both
an input and output value.  This combines the behavior of both the
"INPUT" and "OUTPUT" methods described earlier.  Output values are
returned in the form of a Perl array.

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
function.  Thus, to apply this function to a Perl variable you might
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




