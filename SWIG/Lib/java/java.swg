
%include "javahead.swg"

/* Java typemaps.
 *
 * The jni, jtype and jstype typemaps work together and so there should be one of each. 
 * The jni typemap contains the JNI type used in the JNI (C/C++) code. 
 * The jtype typemap contains the Java type used in the Java module class. 
 * The jstype typemap contains the Java type used in the Java shadow class. */

/* Primitive types */
%typemap(jni) bool,               const bool &               "jboolean"
%typemap(jni) char,               const char &               "jbyte"
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
%typemap(jtype) char,               const char &               "byte"
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
%typemap(jstype) char,               const char &               "byte"
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

/* Non primitive types */
%typemap(jni) SWIGTYPE "jlong"
%typemap(jtype) SWIGTYPE "long"
%typemap(jstype) SWIGTYPE "$javaclassname"

%typemap(jni) SWIGTYPE [] "jlongArray"
%typemap(jtype) SWIGTYPE [] "long[]"
%typemap(jstype) SWIGTYPE [] "$javaclassname[]"

%typemap(jni) SWIGTYPE * "jlong"
%typemap(jtype) SWIGTYPE * "long"
%typemap(jstype) SWIGTYPE * "long"

%typemap(jni) SWIGTYPE & "jlong"
%typemap(jtype) SWIGTYPE & "long"
%typemap(jstype) SWIGTYPE & "long"

%typemap(jni) enum SWIGTYPE "jint"
%typemap(jtype) enum SWIGTYPE "int"
%typemap(jstype) enum SWIGTYPE "int"

/* Arrays of pointers. SWIG doesn't have a default for pointers to arrays, 
 * eg SWIGTYPE *[]. The typemap SWIGTYPE [] is used for all arrays. The
 * typemaps below give some support for arrays of pointers to primitive types. */
%typemap(jni) SWIGTYPE *ARRAYSOFPRIMITIVEPOINTERS[ANY] "jlongArray"
%typemap(jtype) SWIGTYPE *ARRAYSOFPRIMITIVEPOINTERS[ANY] "long[]"
%typemap(jstype) SWIGTYPE *ARRAYSOFPRIMITIVEPOINTERS[ANY] "long[]"

/* Arrays of enum pointers. These typemaps are applied in the source
 * code for all enum declarations, that is the equivalent of:
 * %apply enum SWIGTYPE *[ANY] { name *[ANY] }; */
%typemap(jni) enum SWIGTYPE *[ANY] "jlongArray"
%typemap(jtype) enum SWIGTYPE *[ANY] "long[]"
%typemap(jstype) enum SWIGTYPE *[ANY] "long[]"

/* Arrays of pointers. These typemaps makes it possible to treat an array of c pointers to 
 * class/struct/union as an array of Java classes. These typemaps are applied in the source
 * code for all class/struct/union declarations, that is the equivalent of:
 * %apply SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] { name *[ANY] }; */
%typemap(jni) SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] "jlongArray"
%typemap(jtype) SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] "long[]"
%typemap(jstype) SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] "$javaclassname[]"

/* Arrays of enums. SWIG does not have a default for arrays of enums, eg enum SWIGTYPE []. The following 
 * typemaps are applied in the source code for all enum declarations that is the equivalent of:
 * %apply enum SWIGTYPE[ANY] {name[ANY]}; */
%typemap(jni) enum SWIGTYPE[ANY] "jintArray"
%typemap(jtype) enum SWIGTYPE[ANY] "int[]"
%typemap(jstype) enum SWIGTYPE[ANY] "int[]"

/* Pointers and references to classes. SWIG does not have a default for pointers to classes, eg SWIGTYPE *CLASS. 
 * The following typemaps are applied in the source code for all class/struct/union declarations, that is the equivalent of:
 * %apply SWIGTYPE *CLASS { name * }; 
 * %apply SWIGTYPE &CLASS { name & }; */
%typemap(jni) SWIGTYPE *CLASS "jlong"
%typemap(jtype) SWIGTYPE *CLASS "long"
%typemap(jstype) SWIGTYPE *CLASS "$javaclassname"

%typemap(jni) SWIGTYPE &CLASS "jlong"
%typemap(jtype) SWIGTYPE &CLASS "long"
%typemap(jstype) SWIGTYPE &CLASS "$javaclassname"

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
%typemap(out) char           %{ $result = (jbyte)$1; %}
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
%typemap(in) bool & (bool temp),
             char & (char temp), 
             signed char & (signed char temp), 
             unsigned char & (unsigned char temp), 
             short & (short temp), 
             unsigned short & (unsigned short temp), 
             int & (int temp), 
             unsigned int & (unsigned int temp), 
             long & (long temp), 
             unsigned long & (unsigned long temp), 
             long long & (long long temp), 
             float & (float temp), 
             double & (double temp)
%{ 
temp = ($*1_ltype)$input; 
$1 = &temp;
%}

%typemap(out) const bool &           %{ $result = (jboolean)*$1; %}
%typemap(out) const char &           %{ $result = (jbyte)*$1; %}
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
%{ argp = ($&1_ltype)*(void**)&$input; 
   $1 = *argp; %}

%typemap(out) SWIGTYPE 
#ifdef __cplusplus
%{$&1_ltype $1ptr = new $1_ltype($1);
  *($&1_ltype*)&$result = $1ptr; %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  *($&1_ltype*)&$result = $1ptr;
}
#endif

/* Generic pointers and references */
%typemap(in) SWIGTYPE * , SWIGTYPE & %{ $1 = ($1_ltype)*(void**)&$input; %}
%typemap(out) SWIGTYPE * , SWIGTYPE & %{ *($&1_ltype)&$result = $1; %} 

/* Arrays */
/* bool[ANY] */
%typemap(in) bool[ANY] (jboolean *jarr)
%{ if (!SWIG_JavaArrayInBool(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) bool[ANY] 
%{ SWIG_JavaArrayArgoutBool(jenv, jarr$argnum, $1, $input); %}
%typemap(out) bool[ANY] 
%{$result = SWIG_JavaArrayOutBool(jenv, $1, $1_dim0); %}

/* char[ANY] - treat as String */
%typemap(in) char[ANY] { $1 = ($input) ? ($1_ltype)JCALL2(GetStringUTFChars, jenv, $input, 0) : NULL; }
%typemap(argout) char[ANY] ""
%typemap(freearg) char[ANY] { if ($1) JCALL2(ReleaseStringUTFChars, jenv, $input, $1); }
%typemap(out) char[ANY] { if($1) $result = JCALL1(NewStringUTF, jenv, $1); }

/* signed char[ANY] */
%typemap(in) signed char[ANY] (jbyte *jarr)
%{ if (!SWIG_JavaArrayInSchar(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) signed char[ANY] 
%{ SWIG_JavaArrayArgoutSchar(jenv, jarr$argnum, $1, $input); %}
%typemap(out) signed char[ANY] 
%{$result = SWIG_JavaArrayOutSchar(jenv, $1, $1_dim0); %}

/* unsigned char[ANY] */
%typemap(in) unsigned char[ANY] (jshort *jarr)
%{ if (!SWIG_JavaArrayInUchar(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) unsigned char[ANY] 
%{ SWIG_JavaArrayArgoutUchar(jenv, jarr$argnum, $1, $input); %}
%typemap(out) unsigned char[ANY] 
%{$result = SWIG_JavaArrayOutUchar(jenv, $1, $1_dim0); %}

/* short[ANY] */
%typemap(in) short[ANY] (jshort *jarr)
%{ if (!SWIG_JavaArrayInShort(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) short[ANY] 
%{ SWIG_JavaArrayArgoutShort(jenv, jarr$argnum, $1, $input); %}
%typemap(out) short[ANY] 
%{$result = SWIG_JavaArrayOutShort(jenv, $1, $1_dim0); %}

/* unsigned short[ANY] */
%typemap(in) unsigned short[ANY] (jint *jarr)
%{ if (!SWIG_JavaArrayInUshort(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) unsigned short[ANY] 
%{ SWIG_JavaArrayArgoutUshort(jenv, jarr$argnum, $1, $input); %}
%typemap(out) unsigned short[ANY] 
%{$result = SWIG_JavaArrayOutUshort(jenv, $1, $1_dim0); %}

/* int[ANY] */
%typemap(in) int[ANY] (jint *jarr)
%{ if (!SWIG_JavaArrayInInt(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) int[ANY] 
%{ SWIG_JavaArrayArgoutInt(jenv, jarr$argnum, $1, $input); %}
%typemap(out) int[ANY] 
%{$result = SWIG_JavaArrayOutInt(jenv, $1, $1_dim0); %}

/* unsigned int[ANY] */
%typemap(in) unsigned int[ANY] (jlong *jarr)
%{ if (!SWIG_JavaArrayInUint(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) unsigned int[ANY] 
%{ SWIG_JavaArrayArgoutUint(jenv, jarr$argnum, $1, $input); %}
%typemap(out) unsigned int[ANY] 
%{$result = SWIG_JavaArrayOutUint(jenv, $1, $1_dim0); %}

/* long[ANY] */
%typemap(in) long[ANY] (jint *jarr)
%{ if (!SWIG_JavaArrayInLong(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) long[ANY] 
%{ SWIG_JavaArrayArgoutLong(jenv, jarr$argnum, $1, $input); %}
%typemap(out) long[ANY] 
%{$result = SWIG_JavaArrayOutLong(jenv, $1, $1_dim0); %}

/* unsigned long[ANY] */
%typemap(in) unsigned long[ANY] (jlong *jarr)
%{ if (!SWIG_JavaArrayInUlong(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) unsigned long[ANY] 
%{ SWIG_JavaArrayArgoutUlong(jenv, jarr$argnum, $1, $input); %}
%typemap(out) unsigned long[ANY] 
%{$result = SWIG_JavaArrayOutUlong(jenv, $1, $1_dim0); %}

/* long long[ANY] */
%typemap(in) long long[ANY] (jlong *jarr)
%{ if (!SWIG_JavaArrayInLonglong(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) long long[ANY] 
%{ SWIG_JavaArrayArgoutLonglong(jenv, jarr$argnum, $1, $input); %}
%typemap(out) long long[ANY] 
%{$result = SWIG_JavaArrayOutLonglong(jenv, $1, $1_dim0); %}

/* float[ANY] */
%typemap(in) float[ANY] (jfloat *jarr)
%{ if (!SWIG_JavaArrayInFloat(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) float[ANY] 
%{ SWIG_JavaArrayArgoutFloat(jenv, jarr$argnum, $1, $input); %}
%typemap(out) float[ANY] 
%{$result = SWIG_JavaArrayOutFloat(jenv, $1, $1_dim0); %}

/* double[ANY] */
%typemap(in) double[ANY] (jdouble *jarr)
%{ if (!SWIG_JavaArrayInDouble(jenv, &jarr, &$1, $input)) return $null; %}
%typemap(argout) double[ANY] 
%{ SWIG_JavaArrayArgoutDouble(jenv, jarr$argnum, $1, $input); %}
%typemap(out) double[ANY] 
%{$result = SWIG_JavaArrayOutDouble(jenv, $1, $1_dim0); %}

/* enum SWIGTYPE[ANY] */
%typemap(in) enum SWIGTYPE[ANY] (jint *jarr)
%{ if (!SWIG_JavaArrayInInt(jenv, &jarr, (int**)&$1, $input)) return $null; %}
%typemap(argout) enum SWIGTYPE[ANY] 
%{ SWIG_JavaArrayArgoutInt(jenv, jarr$argnum, (int*)$1, $input); %}
%typemap(out) enum SWIGTYPE[ANY] 
%{$result = SWIG_JavaArrayOutInt(jenv, (int*)$1, $1_dim0); %}

/* Arrays of pointers */
%typemap(in) SWIGTYPE *ARRAYSOFPRIMITIVEPOINTERS[ANY] (jlong *jarr, jsize sz),
             SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY] (jlong *jarr, jsize sz),
             enum SWIGTYPE *[ANY] (jlong *jarr, jsize sz)
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
  $1 = ($1_ltype) calloc(sz, sizeof($*1_ltype));
  if (!$1) {
    SWIG_JavaThrowException(jenv, SWIG_JavaOutOfMemoryError, "calloc failed");
    return $null;
  }
  for (i=0; i<sz; i++) {
    $1[i] = *($1_ltype)&jarr[i];
  }
}

%typemap(argout) SWIGTYPE *ARRAYSOFPRIMITIVEPOINTERS[ANY], 
                  SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY],
                  enum SWIGTYPE *[ANY]
{
  int i;
  for (i=0; i<sz$argnum; i++) {
    jarr$argnum[i] = 0;
    *($1_ltype)&jarr$argnum[i] = $1[i];
  }
  JCALL3(ReleaseLongArrayElements, jenv, $input, jarr$argnum, 0);
}

%typemap(out) SWIGTYPE *ARRAYSOFPRIMITIVEPOINTERS[ANY],
              SWIGTYPE *ARRAYSOFCLASSPOINTERS[ANY],
              enum SWIGTYPE *[ANY]
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

%apply SWIGTYPE *ARRAYSOFPRIMITIVEPOINTERS[ANY] { 
    bool *[ANY], char *[ANY], unsigned char *[ANY], short *[ANY], unsigned short *[ANY], int *[ANY], unsigned int *[ANY], long *[ANY], unsigned long *[ANY], long long *[ANY], /*unsigned long long *[ANY],*/ float *[ANY], double *[ANY], void *[ANY] };


/* Default array handling. Used for arrays of non primitive types. */
%typemap(in) SWIGTYPE [] (jlong *jarr, jsize sz)
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
  $1 = ($1_ltype) calloc(sz, sizeof($*1_ltype));
  if (!$1) {
    SWIG_JavaThrowException(jenv, SWIG_JavaOutOfMemoryError, "calloc failed");
    return $null;
  }
  for (i=0; i<sz; i++) {
    $1[i] = **($1_ltype*)&jarr[i];
  }
}

%typemap(argout) SWIGTYPE []
{
  int i;
  for (i=0; i<sz$argnum; i++) {
    jarr$argnum[i] = 0;
    *($1_ltype*)&jarr$argnum[i] = &$1[i];
  }
  JCALL3(ReleaseLongArrayElements, jenv, $input, jarr$argnum, 0);
}

%typemap(out) SWIGTYPE []
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
    *($1_ltype*)&arr[i] = &$1[i];
  }
  JCALL3(ReleaseLongArrayElements, jenv, $result, arr, 0);
}

/* free memory - required by all the array typemaps */
%typemap(freearg) SWIGTYPE []
%{ free($1); %}


%include "java_arrays.i"


/* Some ANSI C typemaps */

%apply long { size_t };

