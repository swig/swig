/* arrays_java.i
 * These typemaps give more natural support for arrays. The typemaps are not efficient
 * as there is a lot of copying of the array values whenever the array is passed to C/C++ 
 * from Java and visa versa. The Java array is expected to be the same size as the C array.
 * An exception is thrown if they are not.

   Example usage:
   Wrapping:

     %include "arrays_java.i"
     %inline %{
         short FiddleSticks[3];
     %}

   Use from Java like this:

     short[] fs = new short[] {10, 11, 12};
     example.setFiddleSticks(fs);
     fs = example.getFiddleSticks();

 */

/* Primitive array support is a combination of SWIG macros and functions in order to reduce 
 * code bloat and aid maintainability. The SWIG preprocessor expands the macros into functions 
 * for inclusion in the generated code. */

/* Array support functions declarations macro */
%define JAVA_ARRAYS_DECL(CTYPE, JNITYPE, JAVATYPE, JFUNCNAME)
%{
int SWIG_JavaArrayIn##JFUNCNAME (JNIEnv *jenv, JNITYPE **jarr, CTYPE **carr, JNITYPE##Array input);
void SWIG_JavaArrayArgout##JFUNCNAME (JNIEnv *jenv, JNITYPE *jarr, CTYPE *carr, JNITYPE##Array input);
JNITYPE##Array SWIG_JavaArrayOut##JFUNCNAME (JNIEnv *jenv, CTYPE *result, jsize sz);
%}
%enddef

/* Array support functions macro */
%define JAVA_ARRAYS_IMPL(CTYPE, JNITYPE, JAVATYPE, JFUNCNAME)
%{
/* CTYPE[] support */
int SWIG_JavaArrayIn##JFUNCNAME (JNIEnv *jenv, JNITYPE **jarr, CTYPE **carr, JNITYPE##Array input) {
  int i;
  jsize sz;
  if (!input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null array");
    return 0;
  }
  sz = JCALL1(GetArrayLength, jenv, input);
  *jarr = JCALL2(Get##JAVATYPE##ArrayElements, jenv, input, 0);
  if (!*jarr)
    return 0; %}
#ifdef __cplusplus
%{  *carr = new CTYPE[sz]; %}
#else
%{  *carr = (CTYPE*) calloc(sz, sizeof(CTYPE)); %}
#endif
%{  if (!*carr) {
    SWIG_JavaThrowException(jenv, SWIG_JavaOutOfMemoryError, "array memory allocation failed");
    return 0;
  }
  for (i=0; i<sz; i++)
    JAVA_TYPEMAP_ARRAY_ELEMENT_ASSIGN(CTYPE)
  return 1;
}

void SWIG_JavaArrayArgout##JFUNCNAME (JNIEnv *jenv, JNITYPE *jarr, CTYPE *carr, JNITYPE##Array input) {
  int i;
  jsize sz = JCALL1(GetArrayLength, jenv, input);
  for (i=0; i<sz; i++)
    jarr[i] = (JNITYPE)carr[i];
  JCALL3(Release##JAVATYPE##ArrayElements, jenv, input, jarr, 0);
}

JNITYPE##Array SWIG_JavaArrayOut##JFUNCNAME (JNIEnv *jenv, CTYPE *result, jsize sz) {
  JNITYPE *arr;
  int i;
  JNITYPE##Array jresult = JCALL1(New##JAVATYPE##Array, jenv, sz);
  if (!jresult)
    return NULL;
  arr = JCALL2(Get##JAVATYPE##ArrayElements, jenv, jresult, 0);
  if (!arr)
    return NULL;
  for (i=0; i<sz; i++)
    arr[i] = (JNITYPE)result[i];
  JCALL3(Release##JAVATYPE##ArrayElements, jenv, jresult, arr, 0);
  return jresult;
}
%}
%enddef

%{
#if defined(SWIG_NOINCLUDE) || defined(SWIG_NOARRAYS)
%}

#ifdef __cplusplus
JAVA_ARRAYS_DECL(bool, jboolean, Boolean, Bool)       /* bool[] */
#endif

JAVA_ARRAYS_DECL(signed char, jbyte, Byte, Schar)     /* signed char[] */
JAVA_ARRAYS_DECL(unsigned char, jshort, Short, Uchar) /* unsigned char[] */
JAVA_ARRAYS_DECL(short, jshort, Short, Short)         /* short[] */
JAVA_ARRAYS_DECL(unsigned short, jint, Int, Ushort)   /* unsigned short[] */
JAVA_ARRAYS_DECL(int, jint, Int, Int)                 /* int[] */
JAVA_ARRAYS_DECL(unsigned int, jlong, Long, Uint)     /* unsigned int[] */
JAVA_ARRAYS_DECL(long, jint, Int, Long)               /* long[] */
JAVA_ARRAYS_DECL(unsigned long, jlong, Long, Ulong)   /* unsigned long[] */
JAVA_ARRAYS_DECL(jlong, jlong, Long, Longlong)        /* long long[] */
JAVA_ARRAYS_DECL(float, jfloat, Float, Float)         /* float[] */
JAVA_ARRAYS_DECL(double, jdouble, Double, Double)     /* double[] */

%{
#else
%}

#ifdef __cplusplus
/* Bool array element assignment different to other types to keep Visual C++ quiet */
#define JAVA_TYPEMAP_ARRAY_ELEMENT_ASSIGN(CTYPE) (*carr)[i] = ((*jarr)[i] != 0);
JAVA_ARRAYS_IMPL(bool, jboolean, Boolean, Bool)       /* bool[] */
#undef JAVA_TYPEMAP_ARRAY_ELEMENT_ASSIGN
#endif

#define JAVA_TYPEMAP_ARRAY_ELEMENT_ASSIGN(CTYPE) (*carr)[i] = (CTYPE)(*jarr)[i];
JAVA_ARRAYS_IMPL(signed char, jbyte, Byte, Schar)     /* signed char[] */
JAVA_ARRAYS_IMPL(unsigned char, jshort, Short, Uchar) /* unsigned char[] */
JAVA_ARRAYS_IMPL(short, jshort, Short, Short)         /* short[] */
JAVA_ARRAYS_IMPL(unsigned short, jint, Int, Ushort)   /* unsigned short[] */
JAVA_ARRAYS_IMPL(int, jint, Int, Int)                 /* int[] */
JAVA_ARRAYS_IMPL(unsigned int, jlong, Long, Uint)     /* unsigned int[] */
JAVA_ARRAYS_IMPL(long, jint, Int, Long)               /* long[] */
JAVA_ARRAYS_IMPL(unsigned long, jlong, Long, Ulong)   /* unsigned long[] */
JAVA_ARRAYS_IMPL(jlong, jlong, Long, Longlong)        /* long long[] */
JAVA_ARRAYS_IMPL(float, jfloat, Float, Float)         /* float[] */
JAVA_ARRAYS_IMPL(double, jdouble, Double, Double)     /* double[] */

%{
#endif
%}


/* The rest of this file has the array typemaps */

/* Arrays of primitive types.
 * These typemaps are applied merely by including this file. */                     
%typemap(jni) bool[ANY]               "jbooleanArray"
%typemap(jni) signed char[ANY]        "jbyteArray"
%typemap(jni) unsigned char[ANY]      "jshortArray"
%typemap(jni) short[ANY]              "jshortArray"
%typemap(jni) unsigned short[ANY]     "jintArray"
%typemap(jni) int[ANY]                "jintArray"
%typemap(jni) unsigned int[ANY]       "jlongArray"
%typemap(jni) long[ANY]               "jintArray"
%typemap(jni) unsigned long[ANY]      "jlongArray"
%typemap(jni) long long[ANY]          "jlongArray"
/*%typemap(jni) unsigned long long[ANY] "jobjectArray"*/
%typemap(jni) float[ANY]              "jfloatArray"
%typemap(jni) double[ANY]             "jdoubleArray"

%typemap(jtype) bool[ANY]               "boolean[]"
%typemap(jtype) signed char[ANY]        "byte[]"
%typemap(jtype) unsigned char[ANY]      "short[]"
%typemap(jtype) short[ANY]              "short[]"
%typemap(jtype) unsigned short[ANY]     "int[]"
%typemap(jtype) int[ANY]                "int[]"
%typemap(jtype) unsigned int[ANY]       "long[]"
%typemap(jtype) long[ANY]               "int[]"
%typemap(jtype) unsigned long[ANY]      "long[]"
%typemap(jtype) long long[ANY]          "long[]"
/*%typemap(jtype) unsigned long long[ANY] "java.math.BigInteger[]"*/
%typemap(jtype) float[ANY]              "float[]"
%typemap(jtype) double[ANY]             "double[]"

%typemap(jstype) bool[ANY]               "boolean[]"
%typemap(jstype) signed char[ANY]        "byte[]"
%typemap(jstype) unsigned char[ANY]      "short[]"
%typemap(jstype) short[ANY]              "short[]"
%typemap(jstype) unsigned short[ANY]     "int[]"
%typemap(jstype) int[ANY]                "int[]"
%typemap(jstype) unsigned int[ANY]       "long[]"
%typemap(jstype) long[ANY]               "int[]"
%typemap(jstype) unsigned long[ANY]      "long[]"
%typemap(jstype) long long[ANY]          "long[]"
/*%typemap(jstype) unsigned long long[ANY] "java.math.BigInteger[]"*/
%typemap(jstype) float[ANY]              "float[]"
%typemap(jstype) double[ANY]             "double[]"

%typemap(javadirectorin) bool[ANY],
                         signed char[ANY],
                         unsigned char[ANY],
                         short[ANY],
                         unsigned short[ANY],
                         int[ANY],
                         unsigned int[ANY],
                         long[ANY],
                         unsigned long[ANY],
                         long long[ANY],
                         /* unsigned long long[ANY], */
                         float[ANY],
                         double[ANY]
  "$jniinput"

%typemap(javadirectorout) bool[ANY],
                          signed char[ANY],
                          unsigned char[ANY],
                          short[ANY],
                          unsigned short[ANY],
                          int[ANY],
                          unsigned int[ANY],
                          long[ANY],
                          unsigned long[ANY],
                          long long[ANY],
                          /* unsigned long long[ANY], */
                          float[ANY],
                          double[ANY]
  "$javacall"

/* Arrays of primitive types use the following macro. The array typemaps use support functions. */
%define JAVA_ARRAYS_TYPEMAPS(CTYPE, JNITYPE, JFUNCNAME, JNIDESC)

%typemap(in) CTYPE[] (JNITYPE *jarr)
%{  if (!SWIG_JavaArrayIn##JFUNCNAME(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(in) CTYPE[ANY] (JNITYPE *jarr)
%{  if ($input && JCALL1(GetArrayLength, jenv, $input) != $1_size) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "incorrect array size");
    return $null;
  }
  if (!SWIG_JavaArrayIn##JFUNCNAME(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) CTYPE[ANY] 
%{ SWIG_JavaArrayArgout##JFUNCNAME(jenv, jarr$argnum, $1, $input); %}
%typemap(directorin,descriptor=JNIDESC) CTYPE[ANY] 
%{$input = SWIG_JavaArrayOut##JFUNCNAME(jenv, $1, $1_dim0); %}
%typemap(out) CTYPE[ANY] 
%{$result = SWIG_JavaArrayOut##JFUNCNAME(jenv, $1, $1_dim0); %}
%typemap(freearg) CTYPE[ANY] 
#ifdef __cplusplus
%{ delete [] $1; %}
#else
%{ free($1); %}
#endif
%typemap(director_in) CTYPE[ANY] 
%{$result = SWIG_JavaArrayOut##JFUNCNAME(jenv, $1, $1_dim0); %}
%typemap(director_out) CTYPE[] (JNITYPE *jarr)
%{  if (!SWIG_JavaArrayIn##JFUNCNAME(jenv, &jarr, &$1, $input)) return $null; %}

%enddef

JAVA_ARRAYS_TYPEMAPS(bool, jboolean, Bool, "[Z")         /* bool[ANY] */
JAVA_ARRAYS_TYPEMAPS(signed char, jbyte, Schar, "[B")    /* signed char[ANY] */
JAVA_ARRAYS_TYPEMAPS(unsigned char, jshort, Uchar, "[S") /* unsigned char[ANY] */
JAVA_ARRAYS_TYPEMAPS(short, jshort, Short, "[S")         /* short[ANY] */
JAVA_ARRAYS_TYPEMAPS(unsigned short, jint, Ushort, "[I") /* unsigned short[ANY] */
JAVA_ARRAYS_TYPEMAPS(int, jint, Int, "[I")               /* int[ANY] */
JAVA_ARRAYS_TYPEMAPS(unsigned int, jlong, Uint, "[J")    /* unsigned int[ANY] */
JAVA_ARRAYS_TYPEMAPS(long, jint, Long, "[I")             /* long[ANY] */
JAVA_ARRAYS_TYPEMAPS(unsigned long, jlong, Ulong, "[J")  /* unsigned long[ANY] */
JAVA_ARRAYS_TYPEMAPS(long long, jlong, Longlong, "[J")   /* long long[ANY] */
JAVA_ARRAYS_TYPEMAPS(float, jfloat, Float, "[F")         /* float[ANY] */
JAVA_ARRAYS_TYPEMAPS(double, jdouble, Double, "[D")      /* double[ANY] */

%typecheck(SWIG_TYPECHECK_BOOL_ARRAY) /* Java boolean[] */
    bool[ANY]
    ""

%typecheck(SWIG_TYPECHECK_INT8_ARRAY) /* Java byte[] */
    signed char[ANY]
    ""

%typecheck(SWIG_TYPECHECK_INT16_ARRAY) /* Java short[] */
    unsigned char[ANY], 
    short[ANY] 
    ""

%typecheck(SWIG_TYPECHECK_INT32_ARRAY) /* Java int[] */
    unsigned short[ANY], 
    int[ANY], 
    long[ANY]
    ""

%typecheck(SWIG_TYPECHECK_INT64_ARRAY) /* Java long[] */
    unsigned int[ANY], 
    unsigned long[ANY], 
    long long[ANY] 
    ""

%typecheck(SWIG_TYPECHECK_INT128_ARRAY) /* Java BigInteger[] */
    unsigned long long[ANY]
    ""

%typecheck(SWIG_TYPECHECK_FLOAT_ARRAY) /* Java float[] */
    float[ANY]
    ""

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY) /* Java double[] */
    double[ANY]
    ""

%typemap(javain) bool[ANY],
                 signed char[ANY],
                 unsigned char[ANY],
                 short[ANY],
                 unsigned short[ANY],
                 int[ANY],
                 unsigned int[ANY],
                 long[ANY],
                 unsigned long[ANY],
                 long long[ANY],
/*               unsigned long long[ANY], */
                 float[ANY],
                 double[ANY]
    "$javainput"

%typemap(javaout) bool[ANY],
                  signed char[ANY],
                  unsigned char[ANY],
                  short[ANY],
                  unsigned short[ANY],
                  int[ANY],
                  unsigned int[ANY],
                  long[ANY],
                  unsigned long[ANY],
                  long long[ANY],
/*                unsigned long long[ANY], */
                  float[ANY],
                  double[ANY] {
    return $jnicall;
  }


/* Arrays of proxy classes. The typemaps in this macro make it possible to treat an array of 
 * class/struct/unions as an array of Java classes. 
 * Use the following macro to use these typemaps for an array of class/struct/unions called name:
 * JAVA_ARRAYSOFCLASSES(name) */
%define JAVA_ARRAYSOFCLASSES(ARRAYSOFCLASSES)

%typemap(jni) ARRAYSOFCLASSES[ANY] "jlongArray"
%typemap(jtype) ARRAYSOFCLASSES[ANY] "long[]"
%typemap(jstype) ARRAYSOFCLASSES[ANY] "$javaclassname[]"

%typemap(javain) ARRAYSOFCLASSES[ANY] "$javaclassname.cArrayUnwrap($javainput)"
%typemap(javaout) ARRAYSOFCLASSES[ANY] {
    return $javaclassname.cArrayWrap($jnicall, $owner);
  }

%typemap(in) ARRAYSOFCLASSES[] (jlong *jarr, jsize sz)
{
  int i;
  if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null array");
    return $null;
  }
  sz = JCALL1(GetArrayLength, jenv, $input);
  jarr = JCALL2(GetLongArrayElements, jenv, $input, 0);
  if (!jarr) {
    return $null;
  }
#ifdef __cplusplus
  $1 = new $*1_ltype[sz];
#else
  $1 = ($1_ltype) calloc(sz, sizeof($*1_ltype));
#endif
  if (!$1) {
    SWIG_JavaThrowException(jenv, SWIG_JavaOutOfMemoryError, "array memory allocation failed");
    return $null;
  }
  for (i=0; i<sz; i++) {
    $1[i] = **($&1_ltype)&jarr[i];
  }
}

%typemap(in) ARRAYSOFCLASSES[ANY] (jlong *jarr, jsize sz)
{
  int i;
  if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null array");
    return $null;
  }
  sz = JCALL1(GetArrayLength, jenv, $input);
  if (sz != $1_size) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "incorrect array size");
    return $null;
  }
  jarr = JCALL2(GetLongArrayElements, jenv, $input, 0);
  if (!jarr) {
    return $null;
  }
#ifdef __cplusplus
  $1 = new $*1_ltype[sz];
#else
  $1 = ($1_ltype) calloc(sz, sizeof($*1_ltype));
#endif
  if (!$1) {
    SWIG_JavaThrowException(jenv, SWIG_JavaOutOfMemoryError, "array memory allocation failed");
    return $null;
  }
  for (i=0; i<sz; i++) {
    $1[i] = **($&1_ltype)&jarr[i];
  }
}

%typemap(argout) ARRAYSOFCLASSES[ANY]
{
  int i;
  for (i=0; i<sz$argnum; i++) {
    jarr$argnum[i] = 0;
    *($&1_ltype)&jarr$argnum[i] = &$1[i];
  }
  JCALL3(ReleaseLongArrayElements, jenv, $input, jarr$argnum, 0);
}

%typemap(out) ARRAYSOFCLASSES[ANY]
{
  jlong *arr;
  int i;
  $result = JCALL1(NewLongArray, jenv, $1_dim0);
  if (!$result) {
    return $null;
  }
  arr = JCALL2(GetLongArrayElements, jenv, $result, 0);
  if (!arr) {
    return $null;
  }
  for (i=0; i<$1_dim0; i++) {
    arr[i] = 0;
    *($&1_ltype)&arr[i] = &$1[i];
  }
  JCALL3(ReleaseLongArrayElements, jenv, $result, arr, 0);
}

%typemap(freearg) ARRAYSOFCLASSES[ANY]
#ifdef __cplusplus
%{ delete [] $1; %}
#else
%{ free($1); %}
#endif

/* Add some code to the proxy class of the array type for converting between type used in 
 * JNI class (long[]) and type used in proxy class ( ARRAYSOFCLASSES[] ) */
%typemap(javacode) ARRAYSOFCLASSES %{
  protected static long[] cArrayUnwrap($javaclassname[] arrayWrapper) {
      long[] cArray = new long[arrayWrapper.length];
      for (int i=0; i<arrayWrapper.length; i++)
        cArray[i] = $javaclassname.getCPtr(arrayWrapper[i]);
      return cArray;
  }

  protected static $javaclassname[] cArrayWrap(long[] cArray, boolean cMemoryOwn) {
    $javaclassname[] arrayWrapper = new $javaclassname[cArray.length];
    for (int i=0; i<cArray.length; i++)
      arrayWrapper[i] = new $javaclassname(cArray[i], cMemoryOwn);
    return arrayWrapper;
  }
%}

%enddef /* JAVA_ARRAYSOFCLASSES */


/* Arrays of enums. 
 * Use the following to use these typemaps for an array of enums called name:
 * %apply ARRAYSOFENUMS[ANY] { name[ANY] }; */
%typemap(jni) ARRAYSOFENUMS[ANY] "jintArray"
%typemap(jtype) ARRAYSOFENUMS[ANY] "int[]"
%typemap(jstype) ARRAYSOFENUMS[ANY] "int[]"

%typemap(javain) ARRAYSOFENUMS[ANY] "$javainput"
%typemap(javaout) ARRAYSOFENUMS[ANY] {
    return $jnicall;
  }

%typemap(in) ARRAYSOFENUMS[] (jint *jarr)
%{  if (!SWIG_JavaArrayInInt(jenv, &jarr, (int**)&$1, $input)) return $null; %}
%typemap(in) ARRAYSOFENUMS[ANY] (jint *jarr) {
  if ($input && JCALL1(GetArrayLength, jenv, $input) != $1_size) {
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, "incorrect array size");
    return $null;
  }
  if (!SWIG_JavaArrayInInt(jenv, &jarr, (int**)&$1, $input)) return $null;
}
%typemap(argout) ARRAYSOFENUMS[ANY] 
%{ SWIG_JavaArrayArgoutInt(jenv, jarr$argnum, (int*)$1, $input); %}
%typemap(out) ARRAYSOFENUMS[ANY] 
%{$result = SWIG_JavaArrayOutInt(jenv, (int*)$1, $1_dim0); %}
%typemap(freearg) ARRAYSOFENUMS[ANY] 
#ifdef __cplusplus
%{ delete [] $1; %}
#else
%{ free($1); %}
#endif

