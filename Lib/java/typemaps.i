//
// SWIG Typemap library
// William Fulton
// 4 January 2002
//
// Java implementation
//

// ------------------------------------------------------------------------
// Pointer and reference handling
//
// These mappings provide support for input/output arguments and common
// uses for C/C++ pointers and C++ references.
// ------------------------------------------------------------------------

// INPUT typemaps.
// These remap a C pointer or C++ reference to be an "INPUT" value which is passed by value
// instead of reference.

/*
The following methods can be applied to turn a pointer or reference into a simple
"input" value.  That is, instead of passing a pointer or reference to an object,
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
        
        %include "typemaps.i"
        double fadd(double *INPUT, double *INPUT);

or you can use the %apply directive :

        %include "typemaps.i"
        %apply double *INPUT { double *a, double *b };
        double fadd(double *a, double *b);

In Java you could then use it like this:
        double answer = modulename.fadd(10.0, 20.0);

There are no char *INPUT typemaps, however you can apply the signed char * typemaps instead:
        %include "typemaps.i"
        %apply signed char *INPUT {char *input};
        void f(char *input);
*/

%define INPUT_TYPEMAP(CTYPE, JNITYPE, JTYPE, JNIDESC)
%typemap(jni) CTYPE *INPUT "JNITYPE"
%typemap(jtype) CTYPE *INPUT "JTYPE"
%typemap(jstype) CTYPE *INPUT "JTYPE"
%typemap(javain) CTYPE *INPUT "$javainput"
%typemap(javadirectorin) CTYPE *INPUT "$jniinput"
%typemap(javadirectorout) CTYPE *INPUT "$javacall"

%typemap(jni) CTYPE &INPUT "JNITYPE"
%typemap(jtype) CTYPE &INPUT "JTYPE"
%typemap(jstype) CTYPE &INPUT "JTYPE"
%typemap(javain) CTYPE &INPUT "$javainput"
%typemap(javadirectorin) CTYPE *INPUT "$jniinput"
%typemap(javadirectorout) CTYPE *INPUT "$javacall"

%typemap(in) CTYPE *INPUT, CTYPE &INPUT
%{ $1 = ($1_ltype)&$input; %}

%typemap(directorin,descriptor=JNIDESC) CYTPE &INPUT
%{ *(($&1_ltype) $input) = (JNITYPE *) &$1; %}

%typemap(directorin,descriptor=JNIDESC) CTYPE *INPUT
%{ *(($&1_ltype) $input) = (JNITYPE *) $1; %}

%typemap(freearg) CTYPE *INPUT, CTYPE &INPUT ""

%typemap(typecheck) CTYPE *INPUT = CTYPE;
%typemap(typecheck) CTYPE &INPUT = CTYPE;
%enddef

INPUT_TYPEMAP(bool, jboolean, boolean, "Z");
INPUT_TYPEMAP(signed char, jbyte, byte, "B");
INPUT_TYPEMAP(unsigned char, jshort, short, "S");
INPUT_TYPEMAP(short, jshort, short, "S");
INPUT_TYPEMAP(unsigned short, jint, int, "I");
INPUT_TYPEMAP(int, jint, int, "I");
INPUT_TYPEMAP(unsigned int, jlong, long, "J");
INPUT_TYPEMAP(long, jint, int, "I");
INPUT_TYPEMAP(unsigned long, jlong, long, "J");
INPUT_TYPEMAP(long long, jlong, long, "J");
INPUT_TYPEMAP(unsigned long long, jobject, java.math.BigInteger, "Ljava/math/BigInteger;");
INPUT_TYPEMAP(float, jfloat, float, "F");
INPUT_TYPEMAP(double, jdouble, double, "D");

#undef INPUT_TYPEMAP

/* Convert from BigInteger using the toByteArray member function */
/* Overrides the typemap in the INPUT_TYPEMAP macro */
%typemap(in) unsigned long long *INPUT($*1_ltype temp), unsigned long long &INPUT($*1_ltype temp) {
  jclass clazz;
  jmethodID mid;
  jbyteArray ba;
  jbyte* bae;
  jsize sz;
  int i;

  if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "BigInteger null");
    return $null;
  }
  clazz = JCALL1(GetObjectClass, jenv, $input);
  mid = JCALL3(GetMethodID, jenv, clazz, "toByteArray", "()[B");
  ba = (jbyteArray)JCALL2(CallObjectMethod, jenv, $input, mid);
  bae = JCALL2(GetByteArrayElements, jenv, ba, 0);
  sz = JCALL1(GetArrayLength, jenv, ba);
  temp = 0;
  if (bae[0] == 0) {
    for(i=sz-1; i>0; i-- ) {
      temp = (temp << 8) | (unsigned char)bae[sz-i];
    }
  } 
  else {
    for(i=sz; i>=0; i-- ) {
      temp = (temp << 8) | (unsigned char)bae[sz-1-i];
    }
  }
  JCALL3(ReleaseByteArrayElements, jenv, ba, bae, 0);
  $1 = &temp;
}

// OUTPUT typemaps.   These typemaps are used for parameters that
// are output only.   An array replaces the c pointer or reference parameter. 
// The output value is returned in this array passed in. 

/*
The following methods can be applied to turn a pointer or reference into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned.  This works by a 
Java array being passed as a parameter where a c pointer or reference is required. 
As with any Java function, the array is passed by reference so that 
any modifications to the array will be picked up in the calling function.
Note that the array passed in MUST have at least one element, but as the 
c function does not require any input, the value can be set to anything.

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

        %include "typemaps.i"
        double modf(double x, double *OUTPUT);

or you can use the %apply directive :

        %include "typemaps.i"
        %apply double *OUTPUT { double *ip };
        double modf(double x, double *ip);

The Java output of the function would be the function return value and the 
value in the single element array. In Java you would use it like this:

    double[] intptr = {0};
    double fraction = modulename.modf(5,intptr);

There are no char *OUTPUT typemaps, however you can apply the signed char * typemaps instead:
        %include "typemaps.i"
        %apply signed char *OUTPUT {char *output};
        void f(char *output);
*/

/* Java BigInteger[] */
%typecheck(SWIG_TYPECHECK_INT128_ARRAY) SWIGBIGINTEGERARRAY ""

%define OUTPUT_TYPEMAP(CTYPE, JNITYPE, JTYPE, JAVATYPE, JNIDESC, TYPECHECKTYPE)
%typemap(jni) CTYPE *OUTPUT %{JNITYPE##Array%}
%typemap(jtype) CTYPE *OUTPUT "JTYPE[]"
%typemap(jstype) CTYPE *OUTPUT "JTYPE[]"
%typemap(javain) CTYPE *OUTPUT "$javainput"
%typemap(javadirectorin) CTYPE *OUTPUT "$jniinput"
%typemap(javadirectorout) CTYPE *OUTPUT "$javacall"

%typemap(jni) CTYPE &OUTPUT %{JNITYPE##Array%}
%typemap(jtype) CTYPE &OUTPUT "JTYPE[]"
%typemap(jstype) CTYPE &OUTPUT "JTYPE[]"
%typemap(javain) CTYPE &OUTPUT "$javainput"
%typemap(javadirectorin) CTYPE &OUTPUT "$jniinput"
%typemap(javadirectorout) CTYPE &OUTPUT "$javacall"

%typemap(in) CTYPE *OUTPUT($*1_ltype temp), CTYPE &OUTPUT($*1_ltype temp)
{
  if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = &temp; 
}

%typemap(directorin,descriptor=JNIDESC) CTYPE &OUTPUT
%{ *(($&1_ltype) $input = &$1; %}

%typemap(directorin,descriptor=JNIDESC) CTYPE *OUTPUT
%{
#error "Need to provide OUT directorin typemap, CTYPE array length is unknown"
%}

%typemap(freearg) CTYPE *OUTPUT, CTYPE &OUTPUT ""

%typemap(argout) CTYPE *OUTPUT, CTYPE &OUTPUT 
{
  JNITYPE jvalue = (JNITYPE)temp$argnum;
  JCALL4(Set##JAVATYPE##ArrayRegion, jenv, $input, 0, 1, &jvalue);
}

%typemap(typecheck) CTYPE *INOUT = TYPECHECKTYPE;
%typemap(typecheck) CTYPE &INOUT = TYPECHECKTYPE;
%enddef

OUTPUT_TYPEMAP(bool, jboolean, boolean, Boolean, "[Ljava/lang/Boolean;", jbooleanArray);
OUTPUT_TYPEMAP(signed char, jbyte, byte, Byte, "[Ljava/lang/Byte;", jbyteArray);               
OUTPUT_TYPEMAP(unsigned char, jshort, short, Short, "[Ljava/lang/Short;", jshortArray);              
OUTPUT_TYPEMAP(short, jshort, short, Short, "[Ljava/lang/Short;", jshortArray);              
OUTPUT_TYPEMAP(unsigned short, jint, int, Int, "[Ljava/lang/Integer;", jintArray);                
OUTPUT_TYPEMAP(int, jint, int, Int, "[Ljava/lang/Integer;", jintArray);                
OUTPUT_TYPEMAP(unsigned int, jlong, long, Long, "[Ljava/lang/Long;", jlongArray);               
OUTPUT_TYPEMAP(long, jint, int, Int, "[Ljava/lang/Integer;", jintArray);                
OUTPUT_TYPEMAP(unsigned long, jlong, long, Long, "[Ljava/lang/Long;", jlongArray);               
OUTPUT_TYPEMAP(long long, jlong, long, Long, "[Ljava/lang/Long;", jlongArray);               
OUTPUT_TYPEMAP(unsigned long long, jobject, java.math.BigInteger, NOTUSED, "[Ljava/lang/BigInteger;", SWIGBIGINTEGERARRAY);
OUTPUT_TYPEMAP(float, jfloat, float, Float, "[Ljava/lang/Float;", jfloatArray);              
OUTPUT_TYPEMAP(double, jdouble, double, Double, "[Ljava/lang/Double;", jdoubleArray);             

#undef OUTPUT_TYPEMAP

/* Convert to BigInteger - byte array holds number in 2's complement big endian format */
/* Use first element in BigInteger array for output */
/* Overrides the typemap in the OUTPUT_TYPEMAP macro */
%typemap(argout) unsigned long long *OUTPUT, unsigned long long &OUTPUT { 
  jbyteArray ba = JCALL1(NewByteArray, jenv, 9);
  jbyte* bae = JCALL2(GetByteArrayElements, jenv, ba, 0);
  jclass clazz = JCALL1(FindClass, jenv, "java/math/BigInteger");
  jmethodID mid = JCALL3(GetMethodID, jenv, clazz, "<init>", "([B)V");
  jobject bigint;
  int i;

  bae[0] = 0;
  for(i=1; i<9; i++ ) {
    bae[i] = (jbyte)(temp$argnum>>8*(8-i));
  }

  JCALL3(ReleaseByteArrayElements, jenv, ba, bae, 0);
  bigint = JCALL3(NewObject, jenv, clazz, mid, ba);
  JCALL3(SetObjectArrayElement, jenv, $input, 0, bigint);
}

// INOUT
// Mappings for an argument that is both an input and output
// parameter

/*
The following methods can be applied to make a function parameter both
an input and output value.  This combines the behavior of both the
"INPUT" and "OUTPUT" methods described earlier.  Output values are
returned as an element in a Java array.

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

        %include "typemaps.i"
        void neg(double *INOUT);

or you can use the %apply directive :

        %include "typemaps.i"
        %apply double *INOUT { double *x };
        void neg(double *x);

This works similarly to C in that the mapping directly modifies the
input value - the input must be an array with a minimum of one element. 
The element in the array is the input and the output is the element in 
the array.

       double x[] = {5};
       neg(x);

The implementation of the OUTPUT and INOUT typemaps is different to other 
languages in that other languages will return the output value as part 
of the function return value. This difference is due to Java being a typed language.

There are no char *INOUT typemaps, however you can apply the signed char * typemaps instead:
        %include "typemaps.i"
        %apply signed char *INOUT {char *inout};
        void f(char *inout);
*/

%define INOUT_TYPEMAP(CTYPE, JNITYPE, JTYPE, JAVATYPE, JNIDESC, TYPECHECKTYPE)
%typemap(jni) CTYPE *INOUT %{JNITYPE##Array%}
%typemap(jtype) CTYPE *INOUT "JTYPE[]"
%typemap(jstype) CTYPE *INOUT "JTYPE[]"
%typemap(javain) CTYPE *INOUT "$javainput"
%typemap(javadirectorin) CTYPE *INOUT "$jniinput"
%typemap(javadirectorout) CTYPE *INOUT "$javacall"

%typemap(jni) CTYPE &INOUT %{JNITYPE##Array%}
%typemap(jtype) CTYPE &INOUT "JTYPE[]"
%typemap(jstype) CTYPE &INOUT "JTYPE[]"
%typemap(javain) CTYPE &INOUT "$javainput"
%typemap(javadirectorin) CTYPE &INOUT "$jniinput"
%typemap(javadirectorout) CTYPE &INOUT "$javacall"

%typemap(in) CTYPE *INOUT, CTYPE &INOUT {
  if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_ltype) JCALL2(Get##JAVATYPE##ArrayElements, jenv, $input, 0); 
}

%typemap(directorin,descriptor=JNIDESC) CTYPE &INOUT
%{ *(($&1_ltype)&$input) = &$1; %}

%typemap(directorin,descriptor=JNIDESC) CTYPE *INOUT, CTYPE &INOUT
{
#error "Need to provide INOUT directorin typemap, CTYPE array length is unknown"
}

%typemap(freearg) CTYPE *INOUT, CTYPE &INOUT ""

%typemap(argout) CTYPE *INOUT, CTYPE &INOUT
{ JCALL3(Release##JAVATYPE##ArrayElements, jenv, $input, (JNITYPE *)$1, 0); }

%typemap(typecheck) CTYPE *INOUT = TYPECHECKTYPE;
%typemap(typecheck) CTYPE &INOUT = TYPECHECKTYPE;
%enddef

INOUT_TYPEMAP(bool, jboolean, boolean, Boolean, "[Ljava/lang/Boolean;", jbooleanArray); 
INOUT_TYPEMAP(signed char, jbyte, byte, Byte, "[Ljava/lang/Byte;", jbyteArray); 
INOUT_TYPEMAP(unsigned char, jshort, short, Short, "[Ljava/lang/Short;", jshortArray);     
INOUT_TYPEMAP(short, jshort, short, Short, "[Ljava/lang/Short;", jshortArray);
INOUT_TYPEMAP(unsigned short, jint, int, Int, "[Ljava/lang/Integer;", jintArray); 
INOUT_TYPEMAP(int, jint, int, Int, "[Ljava/lang/Integer;", jintArray);
INOUT_TYPEMAP(unsigned int, jlong, long, Long, "[Ljava/lang/Long;", jlongArray); 
INOUT_TYPEMAP(long, jint, int, Int, "[Ljava/lang/Integer;", jintArray);
INOUT_TYPEMAP(unsigned long, jlong, long, Long, "[Ljava/lang/Long;", jlongArray); 
INOUT_TYPEMAP(long long, jlong, long, Long, "[Ljava/lang/Long;", jlongArray);
INOUT_TYPEMAP(unsigned long long, jobject, java.math.BigInteger, NOTUSED, "[Ljava.math.BigInteger;", SWIGBIGINTEGERARRAY);
INOUT_TYPEMAP(float, jfloat, float, Float, "[Ljava/lang/Float;", jfloatArray);
INOUT_TYPEMAP(double, jdouble, double, Double, "[Ljava/lang/Double;", jdoubleArray); 

#undef INOUT_TYPEMAP

/* Override the typemap in the INOUT_TYPEMAP macro */
%typemap(in) unsigned long long *INOUT ($*1_ltype temp), unsigned long long &INOUT ($*1_ltype temp) { 
  jobject bigint;
  jclass clazz;
  jmethodID mid;
  jbyteArray ba;
  jbyte* bae;
  jsize sz;
  int i;

  if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  bigint = JCALL2(GetObjectArrayElement, jenv, $input, 0);
  if (!bigint) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array element null");
    return $null;
  }
  clazz = JCALL1(GetObjectClass, jenv, bigint);
  mid = JCALL3(GetMethodID, jenv, clazz, "toByteArray", "()[B");
  ba = (jbyteArray)JCALL2(CallObjectMethod, jenv, bigint, mid);
  bae = JCALL2(GetByteArrayElements, jenv, ba, 0);
  sz = JCALL1(GetArrayLength, jenv, ba);
  temp = 0;
  if (bae[0] == 0) {
    for(i=sz-1; i>0; i-- ) {
      temp = (temp << 8) | (unsigned char)bae[sz-i];
    }
  } 
  else {
    for(i=sz; i>=0; i-- ) {
      temp = (temp << 8) | (unsigned char)bae[sz-1-i];
    }
  }
  JCALL3(ReleaseByteArrayElements, jenv, ba, bae, 0);
  $1 = &temp;
}

%typemap(argout) unsigned long long *INOUT = unsigned long long *OUTPUT;
%typemap(argout) unsigned long long &INOUT = unsigned long long &OUTPUT;
