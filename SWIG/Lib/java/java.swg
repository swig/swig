
%include "javahead.swg"

/* Java typemaps.
 *
 * The jni, jtype and jstype typemaps work together and so there should be one of each. 
 * The jni typemap contains the JNI type used in the JNI (C/C++) code. 
 * The jtype typemap contains the Java type used in the Java module class. 
 * The jstype typemap contains the Java type used in the Java proxy class. */

/* Primitive types */
%typemap(jni) bool,               const bool &               "jboolean"
%typemap(jni) char,               const char &               "jchar"
%typemap(jni) signed char,        const signed char &        "jbyte"
%typemap(jni) unsigned char,      const unsigned char &      "jshort"
%typemap(jni) short,              const short &              "jshort"
%typemap(jni) unsigned short,     const unsigned short &     "jint"
%typemap(jni) int,                const int &                "jint"
%typemap(jni) unsigned int,       const unsigned int &       "jlong"
%typemap(jni) long,               const long &               "jint"
%typemap(jni) unsigned long,      const unsigned long &      "jlong"
%typemap(jni) long long,          const long long &          "jlong"
%typemap(jni) unsigned long long, const unsigned long long & "jobject"
%typemap(jni) float,              const float &              "jfloat"
%typemap(jni) double,             const double &             "jdouble"
%typemap(jni) char *                                         "jstring"
%typemap(jni) void                                           "void"

%typemap(jtype) bool,               const bool &               "boolean"
%typemap(jtype) char,               const char &               "char"
%typemap(jtype) signed char,        const signed char &        "byte"
%typemap(jtype) unsigned char,      const unsigned char &      "short"
%typemap(jtype) short,              const short &              "short"
%typemap(jtype) unsigned short,     const unsigned short &     "int"
%typemap(jtype) int,                const int &                "int"
%typemap(jtype) unsigned int,       const unsigned int &       "long"
%typemap(jtype) long,               const long &               "int"
%typemap(jtype) unsigned long,      const unsigned long &      "long"
%typemap(jtype) long long,          const long long &          "long"
%typemap(jtype) unsigned long long, const unsigned long long & "java.math.BigInteger"
%typemap(jtype) float,              const float &              "float"
%typemap(jtype) double,             const double &             "double"
%typemap(jtype) char *                                         "String"
%typemap(jtype) void                                           "void"

%typemap(jstype) bool,               const bool &               "boolean"
%typemap(jstype) char,               const char &               "char"
%typemap(jstype) signed char,        const signed char &        "byte"
%typemap(jstype) unsigned char,      const unsigned char &      "short"
%typemap(jstype) short,              const short &              "short"
%typemap(jstype) unsigned short,     const unsigned short &     "int"
%typemap(jstype) int,                const int &                "int"
%typemap(jstype) unsigned int,       const unsigned int &       "long"
%typemap(jstype) long,               const long &               "int"
%typemap(jstype) unsigned long,      const unsigned long &      "long"
%typemap(jstype) long long,          const long long &          "long"
%typemap(jstype) unsigned long long, const unsigned long long & "java.math.BigInteger"
%typemap(jstype) float,              const float &              "float"
%typemap(jstype) double,             const double &             "double"
%typemap(jstype) char *                                         "String"
%typemap(jstype) void                                           "void"

/* Arrays of primitive types */                     
%typemap(jni) bool[ANY]               "jbooleanArray"
%typemap(jni) char[ANY]               "jstring"
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
%typemap(jtype) char[ANY]               "String"
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
%typemap(jstype) char[ANY]               "String"
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

/* JNI types */
%typemap(jni) jboolean      "jboolean"
%typemap(jni) jchar         "jchar"
%typemap(jni) jbyte         "jbyte"
%typemap(jni) jshort        "jshort"
%typemap(jni) jint          "jint"
%typemap(jni) jlong         "jlong"
%typemap(jni) jfloat        "jfloat"
%typemap(jni) jdouble       "jdouble"
%typemap(jni) jstring       "jstring"
%typemap(jni) jobject       "jobject"
%typemap(jni) jbooleanArray "jbooleanArray"
%typemap(jni) jcharArray    "jcharArray"
%typemap(jni) jbyteArray    "jbyteArray"
%typemap(jni) jshortArray   "jshortArray"
%typemap(jni) jintArray     "jintArray"
%typemap(jni) jlongArray    "jlongArray"
%typemap(jni) jfloatArray   "jfloatArray"
%typemap(jni) jdoubleArray  "jdoubleArray"
%typemap(jni) jobjectArray  "jobjectArray"

%typemap(jtype) jboolean      "boolean"
%typemap(jtype) jchar         "char"
%typemap(jtype) jbyte         "byte"
%typemap(jtype) jshort        "short"
%typemap(jtype) jint          "int"
%typemap(jtype) jlong         "long"
%typemap(jtype) jfloat        "float"
%typemap(jtype) jdouble       "double"
%typemap(jtype) jstring       "String"
%typemap(jtype) jobject       "Object"
%typemap(jtype) jbooleanArray "boolean[]"
%typemap(jtype) jcharArray    "char[]"
%typemap(jtype) jbyteArray    "byte[]"
%typemap(jtype) jshortArray   "short[]"
%typemap(jtype) jintArray     "int[]"
%typemap(jtype) jlongArray    "long[]"
%typemap(jtype) jfloatArray   "float[]"
%typemap(jtype) jdoubleArray  "double[]"
%typemap(jtype) jobjectArray  "Object[]"

%typemap(jstype) jboolean      "boolean"
%typemap(jstype) jchar         "char"
%typemap(jstype) jbyte         "byte"
%typemap(jstype) jshort        "short"
%typemap(jstype) jint          "int"
%typemap(jstype) jlong         "long"
%typemap(jstype) jfloat        "float"
%typemap(jstype) jdouble       "double"
%typemap(jstype) jstring       "String"
%typemap(jstype) jobject       "Object"
%typemap(jstype) jbooleanArray "boolean[]"
%typemap(jstype) jcharArray    "char[]"
%typemap(jstype) jbyteArray    "byte[]"
%typemap(jstype) jshortArray   "short[]"
%typemap(jstype) jintArray     "int[]"
%typemap(jstype) jlongArray    "long[]"
%typemap(jstype) jfloatArray   "float[]"
%typemap(jstype) jdoubleArray  "double[]"
%typemap(jstype) jobjectArray  "Object[]"

/* Non primitive types */
%typemap(jni) SWIGTYPE "jlong"
%typemap(jtype) SWIGTYPE "long"
%typemap(jstype) SWIGTYPE "$&javaclassname"

%typemap(jni) SWIGTYPE [] "jlong"
%typemap(jtype) SWIGTYPE [] "long"
%typemap(jstype) SWIGTYPE [] "$javaclassname"

%typemap(jni) SWIGTYPE * "jlong"
%typemap(jtype) SWIGTYPE * "long"
%typemap(jstype) SWIGTYPE * "$javaclassname"

%typemap(jni) SWIGTYPE & "jlong"
%typemap(jtype) SWIGTYPE & "long"
%typemap(jstype) SWIGTYPE & "$javaclassname"

%typemap(jni) enum SWIGTYPE "jint"
%typemap(jtype) enum SWIGTYPE "int"
%typemap(jstype) enum SWIGTYPE "int"

/* Arrays of proxy classes. These typemaps make it possible to treat an array of 
 * class/struct/unions as an array of Java classes. These typemaps are applied in the source
 * code for all class/struct/union declarations, that is the equivalent of:
 * %apply SWIGTYPE ARRAYSOFCLASSES[ANY] { name [ANY] }; */
%typemap(jni) SWIGTYPE ARRAYSOFCLASSES[ANY] "jlongArray"
%typemap(jtype) SWIGTYPE ARRAYSOFCLASSES[ANY] "long[]"
%typemap(jstype) SWIGTYPE ARRAYSOFCLASSES[ANY] "$javaclassname[]"

/* Arrays of pointers to proxy classes. These typemaps make it possible to treat an array of c pointers to 
 * class/struct/union as an array of Java classes. These typemaps are applied in the source
 * code for all class/struct/union declarations, that is the equivalent of:
 * %apply SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] { name *[ANY] }; */
%typemap(jni) SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] "jlongArray"
%typemap(jtype) SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] "long[]"
%typemap(jstype) SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] "$javaclassname[]"

/* Arrays of enums. SWIG does not have a default for arrays of enums, eg enum SWIGTYPE []. The following 
 * typemaps are applied in the source code for all enum declarations, that is the equivalent of:
 * %apply enum SWIGTYPE[ANY] {name[ANY]}; */
%typemap(jni) enum SWIGTYPE[ANY] "jintArray"
%typemap(jtype) enum SWIGTYPE[ANY] "int[]"
%typemap(jstype) enum SWIGTYPE[ANY] "int[]"


/* The following are the in, out, freearg, argout typemaps. These are the JNI code generating typemaps for converting from Java to C and visa versa. */

/* primitive types */
%typemap(in) bool,
             char, 
             signed char, 
             unsigned char, 
             short, 
             unsigned short, 
             int, 
             unsigned int, 
             long, 
             unsigned long, 
             long long, 
             float, 
             double, 
             enum SWIGTYPE
%{ $1 = ($1_ltype)$input; %}

%typemap(out) bool           %{ $result = (jboolean)$1; %}
%typemap(out) char           %{ $result = (jchar)$1; %}
%typemap(out) signed char    %{ $result = (jbyte)$1; %}
%typemap(out) unsigned char  %{ $result = (jshort)$1; %}
%typemap(out) short          %{ $result = (jshort)$1; %}
%typemap(out) unsigned short %{ $result = (jint)$1; %}
%typemap(out) int            %{ $result = (jint)$1; %}
%typemap(out) unsigned int   %{ $result = (jlong)$1; %}
%typemap(out) long           %{ $result = (jint)$1; %}
%typemap(out) unsigned long  %{ $result = (jlong)$1; %}
%typemap(out) long long      %{ $result = (jlong)$1; %}
%typemap(out) float          %{ $result = (jfloat)$1; %}
%typemap(out) double         %{ $result = (jdouble)$1; %}
%typemap(out) enum SWIGTYPE  %{ $result = (jint)$1; %}


/* unsigned long long */
/* Convert from BigInteger using the toByteArray member function */
%typemap(in) unsigned long long { 
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
  $1 = 0;
  if (bae[0] == 0) {
    for(i=sz-1; i>0; i-- ) {
      $1 = ($1 << 8) | (unsigned char)bae[sz-i];
    }
  } 
  else {
    for(i=sz; i>=0; i-- ) {
      $1 = ($1 << 8) | (unsigned char)bae[sz-1-i];
    }
  }
  JCALL3(ReleaseByteArrayElements, jenv, ba, bae, 0);
}

/* Convert to BigInteger - byte array holds number in 2's complement big endian format */
%typemap(out) unsigned long long { 
  jbyteArray ba = JCALL1(NewByteArray, jenv, 9);
  jbyte* bae = JCALL2(GetByteArrayElements, jenv, ba, 0);
  jclass clazz = JCALL1(FindClass, jenv, "java/math/BigInteger");
  jmethodID mid = JCALL3(GetMethodID, jenv, clazz, "<init>", "([B)V");
  jobject bigint;
  int i;

  bae[0] = 0;
  for(i=1; i<9; i++ ) {
    bae[i] = (jbyte)($1>>8*(8-i));
  }

  JCALL3(ReleaseByteArrayElements, jenv, ba, bae, 0);
  bigint = JCALL3(NewObject, jenv, clazz, mid, ba);
  $result = bigint;
}

/* char * - treat as String */
%typemap(in) char * { $1 = ($input) ? ($1_ltype)JCALL2(GetStringUTFChars, jenv, $input, 0) : NULL; }
%typemap(freearg) char * { if ($1) JCALL2(ReleaseStringUTFChars, jenv, $input, $1); }
%typemap(out) char * { if($1) $result = JCALL1(NewStringUTF, jenv, $1); }

/* primitive types by reference */
%typemap(in) const bool & (bool temp),
             const char & (char temp), 
             const signed char & (signed char temp), 
             const unsigned char & (unsigned char temp), 
             const short & (short temp), 
             const unsigned short & (unsigned short temp), 
             const int & (int temp), 
             const unsigned int & (unsigned int temp), 
             const long & (long temp), 
             const unsigned long & (unsigned long temp), 
             const long long & (long long temp), 
             const float & (float temp), 
             const double & (double temp)
%{ temp = ($*1_ltype)$input; 
$1 = &temp; %}

%typemap(out) const bool &           %{ $result = (jboolean)*$1; %}
%typemap(out) const char &           %{ $result = (jchar)*$1; %}
%typemap(out) const signed char &    %{ $result = (jbyte)*$1; %}
%typemap(out) const unsigned char &  %{ $result = (jshort)*$1; %}
%typemap(out) const short &          %{ $result = (jshort)*$1; %}
%typemap(out) const unsigned short & %{ $result = (jint)*$1; %}
%typemap(out) const int &            %{ $result = (jint)*$1; %}
%typemap(out) const unsigned int &   %{ $result = (jlong)*$1; %}
%typemap(out) const long &           %{ $result = (jint)*$1; %}
%typemap(out) const unsigned long &  %{ $result = (jlong)*$1; %}
%typemap(out) const long long &      %{ $result = (jlong)*$1; %}
%typemap(out) const float &          %{ $result = (jfloat)*$1; %}
%typemap(out) const double &         %{ $result = (jdouble)*$1; %}

/* const unsigned long long & */
/* Similar to unsigned long long */
%typemap(in) const unsigned long long & (unsigned long long temp) { 
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
  $1 = &temp;
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
}

%typemap(out) const unsigned long long & { 
  jbyteArray ba = JCALL1(NewByteArray, jenv, 9);
  jbyte* bae = JCALL2(GetByteArrayElements, jenv, ba, 0);
  jclass clazz = JCALL1(FindClass, jenv, "java/math/BigInteger");
  jmethodID mid = JCALL3(GetMethodID, jenv, clazz, "<init>", "([B)V");
  jobject bigint;
  int i;

  bae[0] = 0;
  for(i=1; i<9; i++ ) {
    bae[i] = (jbyte)(*$1>>8*(8-i));
  }

  JCALL3(ReleaseByteArrayElements, jenv, ba, bae, 0);
  bigint = JCALL3(NewObject, jenv, clazz, mid, ba);
  $result = bigint;
}

/* Default handling. Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE ($&1_type argp)
%{ argp = *($&1_ltype*)&$input; 
   $1 = *argp; %}

%typemap(out) SWIGTYPE 
#ifdef __cplusplus
%{$&1_ltype $1ptr = new $1_ltype(($1_ltype &)$1);
  *($&1_ltype*)&$result = $1ptr; %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  *($&1_ltype*)&$result = $1ptr;
}
#endif

/* Generic pointers and references */
%typemap(in) SWIGTYPE *, SWIGTYPE & %{ $1 = *($&1_ltype)&$input; %}
%typemap(out) SWIGTYPE *, SWIGTYPE & %{ *($&1_ltype)&$result = $1; %} 


/* Default array handling */
%typemap(in) SWIGTYPE [] %{ $1 = *($&1_ltype)&$input; %}
%typemap(out) SWIGTYPE [] %{ *($&1_ltype)&$result = $1; %} 

/* Arrays of primitive types use the following macro. The array typemaps use support functions. */
%define JAVA_ARRAYS_TYPEMAPS(CTYPE, JNITYPE, JFUNCNAME)

%typemap(in) CTYPE[ANY] (JNITYPE *jarr)
%{ if (!SWIG_JavaArrayIn##JFUNCNAME(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) CTYPE[ANY] 
%{ SWIG_JavaArrayArgout##JFUNCNAME(jenv, jarr$argnum, $1, $input); %}
%typemap(out) CTYPE[ANY] 
%{$result = SWIG_JavaArrayOut##JFUNCNAME(jenv, $1, $1_dim0); %}
%typemap(freearg) CTYPE[ANY] 
#ifdef __cplusplus
%{ delete [] $1; %}
#else
%{ free($1); %}
#endif

%enddef

JAVA_ARRAYS_TYPEMAPS(bool, jboolean, Bool)         /* bool[ANY] */
JAVA_ARRAYS_TYPEMAPS(signed char, jbyte, Schar)    /* signed char[ANY] */
JAVA_ARRAYS_TYPEMAPS(unsigned char, jshort, Uchar) /* unsigned char[ANY] */
JAVA_ARRAYS_TYPEMAPS(short, jshort, Short)         /* short[ANY] */
JAVA_ARRAYS_TYPEMAPS(unsigned short, jint, Ushort) /* unsigned short[ANY] */
JAVA_ARRAYS_TYPEMAPS(int, jint, Int)               /* int[ANY] */
JAVA_ARRAYS_TYPEMAPS(unsigned int, jlong, Uint)    /* unsigned int[ANY] */
JAVA_ARRAYS_TYPEMAPS(long, jint, Long)             /* long[ANY] */
JAVA_ARRAYS_TYPEMAPS(unsigned long, jlong, Ulong)  /* unsigned long[ANY] */
JAVA_ARRAYS_TYPEMAPS(long long, jlong, Longlong)   /* long long[ANY] */
JAVA_ARRAYS_TYPEMAPS(float, jfloat, Float)         /* float[ANY] */
JAVA_ARRAYS_TYPEMAPS(double, jdouble, Double)      /* double[ANY] */

/* char[ANY] - treat as String */
%typemap(in) char[ANY] { $1 = ($input) ? ($1_ltype)JCALL2(GetStringUTFChars, jenv, $input, 0) : NULL; }
%typemap(argout) char[ANY] ""
%typemap(freearg) char[ANY] { if ($1) JCALL2(ReleaseStringUTFChars, jenv, $input, $1); }
%typemap(out) char[ANY] { if($1) $result = JCALL1(NewStringUTF, jenv, $1); }

/* enum SWIGTYPE[ANY] */
%typemap(in) enum SWIGTYPE[ANY] (jint *jarr)
%{ if (!SWIG_JavaArrayInInt(jenv, &jarr, (int**)&$1, $input)) return $null; %}
%typemap(argout) enum SWIGTYPE[ANY] 
%{ SWIG_JavaArrayArgoutInt(jenv, jarr$argnum, (int*)$1, $input); %}
%typemap(out) enum SWIGTYPE[ANY] 
%{$result = SWIG_JavaArrayOutInt(jenv, (int*)$1, $1_dim0); %}
%typemap(freearg) enum SWIGTYPE[ANY] 
#ifdef __cplusplus
%{ delete [] $1; %}
#else
%{ free($1); %}
#endif

/* Arrays of pointers to proxy classes */
%typemap(in) SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] (jlong *jarr, jsize sz)
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
    $1[i] = *($1_ltype)&jarr[i];
  }
}

%typemap(argout) SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY]
{
  int i;
  for (i=0; i<sz$argnum; i++) {
    jarr$argnum[i] = 0;
    *($1_ltype)&jarr$argnum[i] = $1[i];
  }
  JCALL3(ReleaseLongArrayElements, jenv, $input, jarr$argnum, 0);
}

%typemap(out) SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY]
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
    *($1_ltype)&arr[i] = $1[i];
  }
  JCALL3(ReleaseLongArrayElements, jenv, $result, arr, 0);
}

%typemap(freearg) SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY]
#ifdef __cplusplus
%{ delete [] $1; %}
#else
%{ free($1); %}
#endif

/* Arrays of proxy classes */
%typemap(in) SWIGTYPE ARRAYSOFCLASSES[ANY] (jlong *jarr, jsize sz)
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

%typemap(argout) SWIGTYPE ARRAYSOFCLASSES[ANY]
{
  int i;
  for (i=0; i<sz$argnum; i++) {
    jarr$argnum[i] = 0;
    *($&1_ltype)&jarr$argnum[i] = &$1[i];
  }
  JCALL3(ReleaseLongArrayElements, jenv, $input, jarr$argnum, 0);
}

%typemap(out) SWIGTYPE ARRAYSOFCLASSES[ANY]
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

%typemap(freearg) SWIGTYPE ARRAYSOFCLASSES[ANY]
#ifdef __cplusplus
%{ delete [] $1; %}
#else
%{ free($1); %}
#endif

/* JNI types */
%typemap(in) jboolean,
             jchar,
             jbyte,
             jshort,
             jint,
             jlong,
             jfloat,
             jdouble,
             jstring,
             jobject,
             jbooleanArray,
             jcharArray,
             jbyteArray,
             jshortArray,
             jintArray,
             jlongArray,
             jfloatArray,
             jdoubleArray,
             jobjectArray
%{ $1 = $input; %}

%typemap(out) jboolean,
              jchar,
              jbyte,
              jshort,
              jint,
              jlong,
              jfloat,
              jdouble,
              jstring,
              jobject,
              jbooleanArray,
              jcharArray,
              jbyteArray,
              jshortArray,
              jintArray,
              jlongArray,
              jfloatArray,
              jdoubleArray,
              jobjectArray
%{ $result = $1; %}


/* Typecheck typemaps - The purpose of these is merely to issue a warning for overloaded C++ functions 
 * that cannot be overloaded in Java as more than one C++ type maps to a single Java type */

%typecheck(SWIG_TYPECHECK_BOOL) /* Java boolean */
    jboolean,
    bool,
    const bool &
    ""

%typecheck(SWIG_TYPECHECK_CHAR) /* Java char */
    jchar,
    char, 
    const char &
    ""

%typecheck(SWIG_TYPECHECK_INT8) /* Java byte */
    jbyte,
    signed char,
    const signed char &
    ""

%typecheck(SWIG_TYPECHECK_INT16) /* Java short */
    jshort,
    unsigned char, 
    short, 
    const unsigned char &, 
    const short &
    ""

%typecheck(SWIG_TYPECHECK_INT32) /* Java int */
    jint,
    unsigned short, 
    int, 
    long, 
    const unsigned short &, 
    const int &, 
    const long &,
    enum SWIGTYPE
    ""

%typecheck(SWIG_TYPECHECK_INT64) /* Java long */
    jlong,
    unsigned int, 
    unsigned long, 
    long long, 
    const unsigned int &, 
    const unsigned long &, 
    const long long &
    ""

%typecheck(SWIG_TYPECHECK_INT128) /* Java BigInteger */
    unsigned long long
    ""

%typecheck(SWIG_TYPECHECK_FLOAT) /* Java float */
    jfloat,
    float,
    const float &
    ""

%typecheck(SWIG_TYPECHECK_DOUBLE) /* Java double */
    jdouble,
    double,
    const double &
    ""

%typecheck(SWIG_TYPECHECK_STRING) /* Java String */
    jstring,
    char *,
    char[ANY]
    ""

%define SWIG_TYPECHECK_BOOL_ARRAY        1015    %enddef
%define SWIG_TYPECHECK_INT8_ARRAY        1025    %enddef
%define SWIG_TYPECHECK_INT16_ARRAY       1035    %enddef
%define SWIG_TYPECHECK_INT32_ARRAY       1045    %enddef
%define SWIG_TYPECHECK_INT64_ARRAY       1055    %enddef
%define SWIG_TYPECHECK_INT128_ARRAY      1065    %enddef
%define SWIG_TYPECHECK_FLOAT_ARRAY       1080    %enddef
%define SWIG_TYPECHECK_DOUBLE_ARRAY      1090    %enddef
%define SWIG_TYPECHECK_CHAR_ARRAY        1130    %enddef
%define SWIG_TYPECHECK_STRING_ARRAY      1140    %enddef

%typecheck(SWIG_TYPECHECK_BOOL_ARRAY) /* Java boolean[] */
    jbooleanArray,
    bool[ANY]
    ""

%typecheck(SWIG_TYPECHECK_CHAR_ARRAY) /* Java char[] */
    jcharArray
    ""

%typecheck(SWIG_TYPECHECK_INT8_ARRAY) /* Java byte[] */
    jbyteArray,
    signed char[ANY]
    ""

%typecheck(SWIG_TYPECHECK_INT16_ARRAY) /* Java short[] */
    jshortArray,
    unsigned char[ANY], 
    short[ANY] 
    ""

%typecheck(SWIG_TYPECHECK_INT32_ARRAY) /* Java int[] */
    jintArray,
    unsigned short[ANY], 
    int[ANY], 
    long[ANY], 
    enum SWIGTYPE[ANY]
    ""

%typecheck(SWIG_TYPECHECK_INT64_ARRAY) /* Java long[] */
    jlongArray,
    unsigned int[ANY], 
    unsigned long[ANY], 
    long long[ANY] 
    ""

%typecheck(SWIG_TYPECHECK_INT128_ARRAY) /* Java BigInteger[] */
    unsigned long long[ANY]
    ""

%typecheck(SWIG_TYPECHECK_FLOAT_ARRAY) /* Java float[] */
    jfloatArray,
    float[ANY]
    ""

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY) /* Java double[] */
    jdoubleArray,
    double[ANY]
    ""

%typecheck(SWIG_TYPECHECK_POINTER) /* Default */
    SWIGTYPE, 
    SWIGTYPE *, 
    SWIGTYPE &, 
    SWIGTYPE []
    ""


/* Exception handling */

%typemap(throws) int, 
                  long, 
                  short, 
                  unsigned int, 
                  unsigned long, 
                  unsigned short {
  char error_msg[256];
  sprintf(error_msg, "C++ $1_type exception thrown, value: %d", $1);
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, error_msg);
  return $null;
}

%typemap(throws) SWIGTYPE {
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown");
  return $null;
}

%typemap(throws) char * {
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, $1);
  return $null;
}


/* Some ANSI C typemaps */

%apply long { size_t };


/* Typemaps for code generation in proxy classes and Java type wrapper classes */

%typemap(javabase)             SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] ""
%typemap(javaclassmodifiers)   SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] "public"
%typemap(javacode)             SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] ""
%typemap(javaimports)          SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] ""
%typemap(javainterfaces)       SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] ""
%typemap(javaptrconstructormodifiers)   SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] "protected"

%typemap(javafinalize) SWIGTYPE %{
  protected void finalize() {
    delete();
  }
%}

%typemap(javagetcptr) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] %{
  protected static long getCPtr($javaclassname obj) {
    return obj.swigCPtr;
  }
%}

/* Java specific directives */
#define %javaconst(flag)     %feature("java:const","flag")
#define %javamethodmodifiers %feature("java:methodmodifiers")

%javamethodmodifiers "public";


