//
// SWIG Typemap library
// William Fulton
// 4 January 2002
//
// Java implementation
//
// Disclaimer : Unless you really understand how typemaps work, this file
// probably isn't going to make much sense.
//
#ifdef AUTODOC
%section "Typemap Library (Java)",info,after,pre,nosort,skip=1,chop_left=3,chop_right=0,chop_top=0,chop_bottom=0
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

        signed char        *INPUT
        unsigned char      *INPUT
        short              *INPUT
        unsigned short     *INPUT
        int                *INPUT
        unsigned int       *INPUT
        long               *INPUT
        unsigned long      *INPUT
        long long          *INPUT
        unsigned long long *INPUT
        float              *INPUT
        double             *INPUT
        bool               *INPUT
         
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

In Java you could then use it like this:
        double answer = modulename.fadd(10.0 + 20.0);

%}
#endif

%typemap(jni) signed char        *INPUT "jbyte"
%typemap(jni) unsigned char      *INPUT "jshort"
%typemap(jni) short              *INPUT "jshort"
%typemap(jni) unsigned short     *INPUT "jint"
%typemap(jni) int                *INPUT "jint"
%typemap(jni) unsigned int       *INPUT "jlong"
%typemap(jni) long               *INPUT "jint"
%typemap(jni) unsigned long      *INPUT "jlong"
%typemap(jni) long long          *INPUT "jlong"
%typemap(jni) unsigned long long *INPUT "jobject"
%typemap(jni) float              *INPUT "jfloat"
%typemap(jni) double             *INPUT "jdouble"
%typemap(jni) bool               *INPUT "jboolean"

%typemap(jtype) signed char        *INPUT "byte"
%typemap(jtype) unsigned char      *INPUT "short"
%typemap(jtype) short              *INPUT "short"
%typemap(jtype) unsigned short     *INPUT "int"
%typemap(jtype) int                *INPUT "int"
%typemap(jtype) unsigned int       *INPUT "long"
%typemap(jtype) long               *INPUT "int"
%typemap(jtype) unsigned long      *INPUT "long"
%typemap(jtype) long long          *INPUT "long"
%typemap(jtype) unsigned long long *INPUT "java.math.BigInteger"
%typemap(jtype) float              *INPUT "float"
%typemap(jtype) double             *INPUT "double"
%typemap(jtype) bool               *INPUT "boolean"

%typemap(jstype) signed char        *INPUT "byte"
%typemap(jstype) unsigned char      *INPUT "short"
%typemap(jstype) short              *INPUT "short"
%typemap(jstype) unsigned short     *INPUT "int"
%typemap(jstype) int                *INPUT "int"
%typemap(jstype) unsigned int       *INPUT "long"
%typemap(jstype) long               *INPUT "int"
%typemap(jstype) unsigned long      *INPUT "long"
%typemap(jstype) long long          *INPUT "long"
%typemap(jstype) unsigned long long *INPUT "java.math.BigInteger"
%typemap(jstype) float              *INPUT "float"
%typemap(jstype) double             *INPUT "double"
%typemap(jstype) bool               *INPUT "boolean"

%typemap(in) signed char    *INPUT,
             unsigned char  *INPUT,
             short          *INPUT,
             unsigned short *INPUT,
             int            *INPUT,
             unsigned int   *INPUT,
             long           *INPUT,
             unsigned long  *INPUT,
             long long      *INPUT,
             float          *INPUT,
             double         *INPUT,
             bool           *INPUT
  %{ $1 = ($1_type)&$input; %}

/* Convert from BigInteger using the toByteArray member function */
%typemap(in) unsigned long long *INPUT($*1_type temp) {
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
// are output only.   An array replaces the c pointer parameter. 
// The output value is returned in this array passed in. 

#ifdef AUTODOC
%subsection "Output Methods"

%text %{
The following methods can be applied to turn a pointer into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned.  This works by a 
Java array being passed as a parameter where a c pointer is required. 
As with any Java function, the array is passed by reference so that 
any modifications to the array will be picked up in the calling function.
Note that the array passed in MUST have at least one element, but as the 
c function does not require any input, the value can be set to anything.

        signed char        *OUTPUT
        unsigned char      *OUTPUT
        short              *OUTPUT
        unsigned short     *OUTPUT
        int                *OUTPUT
        unsigned int       *OUTPUT
        long               *OUTPUT
        unsigned long      *OUTPUT
        long long          *OUTPUT
        unsigned long long *OUTPUT
        float              *OUTPUT
        double             *OUTPUT
        bool               *OUTPUT
         
For example, suppose you were trying to wrap the modf() function in the
C math library which splits x into integral and fractional parts (and
returns the integer part in one of its parameters):

        double modf(double x, double *ip);

You could wrap it with SWIG as follows :

        %include typemaps.i
        double modf(double x, double *OUTPUT);

or you can use the %apply directive :

        %include typemaps.i
        %apply double *OUTPUT { double *ip };
        double modf(double x, double *ip);

The Java output of the function would be the function return value and the 
value in the single element array. In Java you would use it like this:

    double[] intptr = {0};
    double fraction = modulename.modf(5,intptr);

%}
#endif

%typemap(jni) signed char        *OUTPUT "jbyteArray"
%typemap(jni) unsigned char      *OUTPUT "jshortArray"
%typemap(jni) short              *OUTPUT "jshortArray"
%typemap(jni) unsigned short     *OUTPUT "jintArray"
%typemap(jni) int                *OUTPUT "jintArray"
%typemap(jni) unsigned int       *OUTPUT "jlongArray"
%typemap(jni) long               *OUTPUT "jintArray"
%typemap(jni) unsigned long      *OUTPUT "jlongArray"
%typemap(jni) long long          *OUTPUT "jlongArray"
%typemap(jni) unsigned long long *OUTPUT "jobjectArray"
%typemap(jni) float              *OUTPUT "jfloatArray"
%typemap(jni) double             *OUTPUT "jdoubleArray"
%typemap(jni) bool               *OUTPUT "jbooleanArray"

%typemap(jtype) signed char        *OUTPUT "byte[]"
%typemap(jtype) unsigned char      *OUTPUT "short[]"
%typemap(jtype) short              *OUTPUT "short[]"
%typemap(jtype) unsigned short     *OUTPUT "int[]"
%typemap(jtype) int                *OUTPUT "int[]"
%typemap(jtype) unsigned int       *OUTPUT "long[]"
%typemap(jtype) long               *OUTPUT "int[]"
%typemap(jtype) unsigned long      *OUTPUT "long[]"
%typemap(jtype) long long          *OUTPUT "long[]"
%typemap(jtype) unsigned long long *OUTPUT "java.math.BigInteger[]"
%typemap(jtype) float              *OUTPUT "float[]"
%typemap(jtype) double             *OUTPUT "double[]"
%typemap(jtype) bool               *OUTPUT "boolean[]"

%typemap(jstype) signed char        *OUTPUT "byte[]"
%typemap(jstype) unsigned char      *OUTPUT "short[]"
%typemap(jstype) short              *OUTPUT "short[]"
%typemap(jstype) unsigned short     *OUTPUT "int[]"
%typemap(jstype) int                *OUTPUT "int[]"
%typemap(jstype) unsigned int       *OUTPUT "long[]"
%typemap(jstype) long               *OUTPUT "int[]"
%typemap(jstype) unsigned long      *OUTPUT "long[]"
%typemap(jstype) long long          *OUTPUT "long[]"
%typemap(jstype) unsigned long long *OUTPUT "java.math.BigInteger[]"
%typemap(jstype) float              *OUTPUT "float[]"
%typemap(jstype) double             *OUTPUT "double[]"
%typemap(jstype) bool               *OUTPUT "boolean[]"

%typemap(in) signed char        *OUTPUT($*1_type temp),
             unsigned char      *OUTPUT($*1_type temp),
             short              *OUTPUT($*1_type temp),
             unsigned short     *OUTPUT($*1_type temp),
             int                *OUTPUT($*1_type temp),
             unsigned int       *OUTPUT($*1_type temp),
             long               *OUTPUT($*1_type temp),
             unsigned long      *OUTPUT($*1_type temp),
             long long          *OUTPUT($*1_type temp),
             unsigned long long *OUTPUT($*1_type temp),
             float              *OUTPUT($*1_type temp),
             double             *OUTPUT($*1_type temp),
             bool               *OUTPUT($*1_type temp)
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = &temp; %}

%typemap(argout) signed char        *OUTPUT %{ JCALL4(SetByteArrayRegion, jenv, $input, 0, 1, (jbyte *)&temp$argnum); %}
%typemap(argout) unsigned char      *OUTPUT %{ JCALL4(SetShortArrayRegion, jenv, $input, 0, 1, (jshort *)&temp$argnum); %}
%typemap(argout) short              *OUTPUT %{ JCALL4(SetShortArrayRegion, jenv, $input, 0, 1, (jshort *)&temp$argnum); %}
%typemap(argout) unsigned short     *OUTPUT %{ JCALL4(SetIntArrayRegion, jenv, $input, 0, 1, (jint *)&temp$argnum); %}
%typemap(argout) int                *OUTPUT %{ JCALL4(SetIntArrayRegion, jenv, $input, 0, 1, (jint *)&temp$argnum); %}
%typemap(argout) unsigned int       *OUTPUT %{ JCALL4(SetLongArrayRegion, jenv, $input, 0, 1, (jlong *)&temp$argnum); %}
%typemap(argout) long               *OUTPUT %{ JCALL4(SetIntArrayRegion, jenv, $input, 0, 1, (jint *)&temp$argnum); %}
%typemap(argout) unsigned long      *OUTPUT %{ JCALL4(SetLongArrayRegion, jenv, $input, 0, 1, (jlong *)&temp$argnum); %}
%typemap(argout) long long          *OUTPUT %{ JCALL4(SetLongArrayRegion, jenv, $input, 0, 1, (jlong *)&temp$argnum); %}
%typemap(argout) float              *OUTPUT %{ JCALL4(SetFloatArrayRegion, jenv, $input, 0, 1, (jfloat *)&temp$argnum); %}
%typemap(argout) double             *OUTPUT %{ JCALL4(SetDoubleArrayRegion, jenv, $input, 0, 1, (fdouble *)&temp$argnum); %}
%typemap(argout) bool               *OUTPUT %{ JCALL4(SetBooleanArrayRegion, jenv, $input, 0, 1, (jboolean *)&temp$argnum); %}

/* Convert to BigInteger - byte array holds number in 2's complement big endian format */
/* Use first element in BigInteger array for output */
%typemap(argout) unsigned long long *OUTPUT { 
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


#ifdef AUTODOC
%subsection "Input/Output Methods"

%text %{
The following methods can be applied to make a function parameter both
an input and output value.  This combines the behavior of both the
"INPUT" and "OUTPUT" methods described earlier.  Output values are
returned as an element in a Java array.

        signed char        *INOUT
        unsigned char      *INOUT
        short              *INOUT
        unsigned short     *INOUT
        int                *INOUT
        unsigned int       *INOUT
        long               *INOUT
        unsigned long      *INOUT
        long long          *INOUT
        unsigned long long *INOUT
        float              *INOUT
        double             *INOUT
        bool               *INOUT
         
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

This works similarly to C in that the mapping directly modifies the
input value - the input must be an array with a minimum of one element. 
The element in the array is the input and the output is the element in 
the array.

       double x[] = {5};
       neg(x);

The implementation of the OUTPUT and INOUT typemaps is different to other 
languages in that other languages will return the output value as part 
of the function return value. This is due to Java being a typed language.

%}

#endif
%typemap(jni) signed char        *INOUT = signed char        *OUTPUT;
%typemap(jni) unsigned char      *INOUT = unsigned char      *OUTPUT;
%typemap(jni) short              *INOUT = short              *OUTPUT;
%typemap(jni) unsigned short     *INOUT = unsigned short     *OUTPUT;
%typemap(jni) int                *INOUT = int                *OUTPUT;
%typemap(jni) unsigned int       *INOUT = unsigned int       *OUTPUT;
%typemap(jni) long               *INOUT = long               *OUTPUT;
%typemap(jni) unsigned long      *INOUT = unsigned long      *OUTPUT;
%typemap(jni) long long          *INOUT = long long          *OUTPUT;
%typemap(jni) unsigned long long *INOUT = unsigned long long *OUTPUT;
%typemap(jni) float              *INOUT = float              *OUTPUT;
%typemap(jni) double             *INOUT = double             *OUTPUT;
%typemap(jni) bool               *INOUT = bool               *OUTPUT;

%typemap(jtype) signed char        *INOUT = signed char        *OUTPUT;
%typemap(jtype) unsigned char      *INOUT = unsigned char      *OUTPUT;
%typemap(jtype) short              *INOUT = short              *OUTPUT;
%typemap(jtype) unsigned short     *INOUT = unsigned short     *OUTPUT;
%typemap(jtype) int                *INOUT = int                *OUTPUT;
%typemap(jtype) unsigned int       *INOUT = unsigned int       *OUTPUT;
%typemap(jtype) long               *INOUT = long               *OUTPUT;
%typemap(jtype) unsigned long      *INOUT = unsigned long      *OUTPUT;
%typemap(jtype) long long          *INOUT = long long          *OUTPUT;
%typemap(jtype) unsigned long long *INOUT = unsigned long long *OUTPUT;
%typemap(jtype) float              *INOUT = float              *OUTPUT;
%typemap(jtype) double             *INOUT = double             *OUTPUT;
%typemap(jtype) bool               *INOUT = bool               *OUTPUT;

%typemap(jstype) signed char        *INOUT = signed char        *OUTPUT;
%typemap(jstype) unsigned char      *INOUT = unsigned char      *OUTPUT;
%typemap(jstype) short              *INOUT = short              *OUTPUT;
%typemap(jstype) unsigned short     *INOUT = unsigned short     *OUTPUT;
%typemap(jstype) int                *INOUT = int                *OUTPUT;
%typemap(jstype) unsigned int       *INOUT = unsigned int       *OUTPUT;
%typemap(jstype) long               *INOUT = long               *OUTPUT;
%typemap(jstype) unsigned long      *INOUT = unsigned long      *OUTPUT;
%typemap(jstype) long long          *INOUT = long long          *OUTPUT;
%typemap(jstype) unsigned long long *INOUT = unsigned long long *OUTPUT;
%typemap(jstype) float              *INOUT = float              *OUTPUT;
%typemap(jstype) double             *INOUT = double             *OUTPUT;
%typemap(jstype) bool               *INOUT = bool               *OUTPUT;

/* Note: most of this common code will be put in a function in the near future. */
%typemap(in) signed char        *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetByteArrayElements, jenv, $input, 0); %}

%typemap(in) unsigned char      *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetShortArrayElements, jenv, $input, 0); %}

%typemap(in) short              *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetShortArrayElements, jenv, $input, 0); %}

%typemap(in) unsigned short     *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetIntArrayElements, jenv, $input, 0); %}

%typemap(in) int                *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetIntArrayElements, jenv, $input, 0); %}

%typemap(in) unsigned int       *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetLongArrayElements, jenv, $input, 0); %}

%typemap(in) long               *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetIntArrayElements, jenv, $input, 0); %}

%typemap(in) unsigned long      *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetLongArrayElements, jenv, $input, 0); %}

%typemap(in) long long          *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetLongArrayElements, jenv, $input, 0); %}

%typemap(in) float              *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetFloatArrayElements, jenv, $input, 0); %}

%typemap(in) double             *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetDoubleArrayElements, jenv, $input, 0); %}

%typemap(in) bool               *INOUT 
%{if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "array null");
    return $null;
  }
  if (JCALL1(GetArrayLength, jenv, $input) == 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "Array must contain at least 1 element");
    return $null;
  }
  $1 = ($1_type) JCALL2(GetBooleanArrayElements, jenv, $input, 0); %}

%typemap(in) unsigned long long *INOUT ($*1_type temp) { 
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

%typemap(argout) signed char        *INOUT %{ JCALL3(ReleaseByteArrayElements, jenv, $input, (jbyte *)$1, 0); %}
%typemap(argout) unsigned char      *INOUT %{ JCALL3(ReleaseShortArrayElements, jenv, $input, (jshort *)$1, 0); %}
%typemap(argout) short              *INOUT %{ JCALL3(ReleaseShortArrayElements, jenv, $input, (jshort *)$1, 0); %}
%typemap(argout) unsigned short     *INOUT %{ JCALL3(ReleaseIntArrayElements, jenv, $input, (jint *)$1, 0); %}
%typemap(argout) int                *INOUT %{ JCALL3(ReleaseIntArrayElements, jenv, $input, (jint *)$1, 0); %}
%typemap(argout) unsigned int       *INOUT %{ JCALL3(ReleaseLongArrayElements, jenv, $input, (jlong *)$1, 0); %}
%typemap(argout) long               *INOUT %{ JCALL3(ReleaseIntArrayElements, jenv, $input, (jint *)$1, 0); %}
%typemap(argout) unsigned long      *INOUT %{ JCALL3(ReleaseLongArrayElements, jenv, $input, (jlong *)$1, 0); %}
%typemap(argout) long long          *INOUT %{ JCALL3(ReleaseLongArrayElements, jenv, $input, (jlong *)$1, 0); %}
%typemap(argout) float              *INOUT %{ JCALL3(ReleaseFloatArrayElements, jenv, $input, (jfloat *)$1, 0); %}
%typemap(argout) double             *INOUT %{ JCALL3(ReleaseDoubleArrayElements, jenv, $input, (jdouble *)$1, 0); %}
%typemap(argout) bool               *INOUT %{ JCALL3(ReleaseBooleanArrayElements, jenv, $input, (jboolean *)$1, 0); %}
%typemap(argout) unsigned long long *INOUT = unsigned long long *OUTPUT;

