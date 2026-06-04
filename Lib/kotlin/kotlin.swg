/* -----------------------------------------------------------------------------
 * kotlin.swg
 *
 * Java typemaps
 * ----------------------------------------------------------------------------- */

%include <kotlinhead.swg>

/* The jni, ktype and kstype typemaps work together and so there should be one of each. 
 * The jni typemap contains the JNI type used in the JNI (C/C++) code. 
 * The ktype typemap contains the Java type used in the JNI intermediary class. 
 * The kstype typemap contains the Java type used in the Java proxy classes, type wrapper classes and module class. */

/* Fragments */
%fragment("SWIG_PackData", "header") {
/* Pack binary data into a string */
SWIGINTERN char * SWIG_PackData(char *c, void *ptr, size_t sz) {
  static const char hex[17] = "0123456789abcdef";
  const unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu =  u + sz;
  for (; u != eu; ++u) {
    unsigned char uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}
}

%fragment("SWIG_UnPackData", "header") {
/* Unpack binary data from a string */
SWIGINTERN const char * SWIG_UnpackData(const char *c, void *ptr, size_t sz) {
  unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu = u + sz;
  for (; u != eu; ++u) {
    char d = *(c++);
    unsigned char uu;
    if ((d >= '0') && (d <= '9'))
      uu = ((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = ((d - ('a'-10)) << 4);
    else 
      return (char *) 0;
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (d - ('a'-10));
    else 
      return (char *) 0;
    *u = uu;
  }
  return c;
}
}

%fragment("SWIG_JavaIntFromSize_t", "header") {
/* Check for overflow converting to Java int (always signed 32-bit) from (unsigned variable-bit) size_t */
SWIGINTERN jint SWIG_JavaIntFromSize_t(size_t size) {
  static const jint JINT_MAX = 0x7FFFFFFF;
  return (size > (size_t)JINT_MAX) ? -1 : (jint)size;
}
}

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
%typemap(jni) void                                           "void"

%typemap(ktype) bool,               const bool &               "Boolean"
%typemap(ktype) char,               const char &               "Char"
%typemap(ktype) signed char,        const signed char &        "Byte"
%typemap(ktype) unsigned char,      const unsigned char &      "Short"
%typemap(ktype) short,              const short &              "Short"
%typemap(ktype) unsigned short,     const unsigned short &     "Int"
%typemap(ktype) int,                const int &                "Int"
%typemap(ktype) unsigned int,       const unsigned int &       "Long"
%typemap(ktype) long,               const long &               "Int"
%typemap(ktype) unsigned long,      const unsigned long &      "Long"
%typemap(ktype) long long,          const long long &          "Long"
%typemap(ktype) unsigned long long, const unsigned long long & "java.math.BigInteger"
%typemap(ktype) float,              const float &              "Float"
%typemap(ktype) double,             const double &             "Double"
%typemap(ktype) void                                           "Unit"

%typemap(kstype) bool,               const bool &               "Boolean"
%typemap(kstype) char,               const char &               "Char"
%typemap(kstype) signed char,        const signed char &        "Byte"
%typemap(kstype) unsigned char,      const unsigned char &      "Short"
%typemap(kstype) short,              const short &              "Short"
%typemap(kstype) unsigned short,     const unsigned short &     "Int"
%typemap(kstype) int,                const int &                "Int"
%typemap(kstype) unsigned int,       const unsigned int &       "Long"
%typemap(kstype) long,               const long &               "Int"
%typemap(kstype) unsigned long,      const unsigned long &      "Long"
%typemap(kstype) long long,          const long long &          "Long"
%typemap(kstype) unsigned long long, const unsigned long long & "java.math.BigInteger"
%typemap(kstype) float,              const float &              "Float"
%typemap(kstype) double,             const double &             "Double"
%typemap(kstype) void                                           "Unit"

%typemap(kboxtype) bool,               const bool &               "Boolean"
%typemap(kboxtype) char,               const char &               "Char"
%typemap(kboxtype) signed char,        const signed char &        "Byte"
%typemap(kboxtype) unsigned char,      const unsigned char &      "Short"
%typemap(kboxtype) short,              const short &              "Short"
%typemap(kboxtype) unsigned short,     const unsigned short &     "Int"
%typemap(kboxtype) int,                const int &                "Int"
%typemap(kboxtype) unsigned int,       const unsigned int &       "Long"
%typemap(kboxtype) long,               const long &               "Int"
%typemap(kboxtype) unsigned long,      const unsigned long &      "Long"
%typemap(kboxtype) long long,          const long long &          "Long"
%typemap(kboxtype) unsigned long long, const unsigned long long & "java.math.BigInteger"
%typemap(kboxtype) float,              const float &              "Float"
%typemap(kboxtype) double,             const double &             "Double"

%typemap(jni) char *, char *&, char[ANY], char[]               "jstring"
%typemap(ktype) char *, char *&, char[ANY], char[]               "String?"
%typemap(kstype) char *, char *&, char[ANY], char[]               "String?"

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

%typemap(ktype) jboolean      "Boolean"
%typemap(ktype) jchar         "Char"
%typemap(ktype) jbyte         "Byte"
%typemap(ktype) jshort        "Short"
%typemap(ktype) jint          "Int"
%typemap(ktype) jlong         "Long"
%typemap(ktype) jfloat        "Float"
%typemap(ktype) jdouble       "Double"
%typemap(ktype) jstring       "String?"
%typemap(ktype) jobject       "Any?"
%typemap(ktype) jbooleanArray "BooleanArray"
%typemap(ktype) jcharArray    "CharArray"
%typemap(ktype) jbyteArray    "ByteArray?"
%typemap(ktype) jshortArray   "ShortArray"
%typemap(ktype) jintArray     "IntArray"
%typemap(ktype) jlongArray    "LongArray"
%typemap(ktype) jfloatArray   "FloatArray"
%typemap(ktype) jdoubleArray  "DoubleArray"
%typemap(ktype) jobjectArray  "Array<Any?>"

%typemap(kstype) jboolean      "Boolean"
%typemap(kstype) jchar         "Char"
%typemap(kstype) jbyte         "Byte"
%typemap(kstype) jshort        "Short"
%typemap(kstype) jint          "Int"
%typemap(kstype) jlong         "Long"
%typemap(kstype) jfloat        "Float"
%typemap(kstype) jdouble       "Double"
%typemap(kstype) jstring       "String?"
%typemap(kstype) jobject       "Any?"
%typemap(kstype) jbooleanArray "BooleanArray"
%typemap(kstype) jcharArray    "CharArray"
%typemap(kstype) jbyteArray    "ByteArray?"
%typemap(kstype) jshortArray   "ShortArray"
%typemap(kstype) jintArray     "IntArray"
%typemap(kstype) jlongArray    "LongArray"
%typemap(kstype) jfloatArray   "FloatArray"
%typemap(kstype) jdoubleArray  "DoubleArray"
%typemap(kstype) jobjectArray  "Array<Any?>"

/* Non primitive types */
%typemap(jni) SWIGTYPE "jlong"
%typemap(ktype) SWIGTYPE "Long"
%typemap(kstype) SWIGTYPE "$&kotlinclassname"
%typemap(kboxtype) SWIGTYPE "$typemap(kstype, $1_type)"

%typemap(jni) SWIGTYPE [] "jlong"
%typemap(ktype) SWIGTYPE [] "Long"
%typemap(kstype) SWIGTYPE [] "$kotlinclassname?"

%typemap(jni) SWIGTYPE * "jlong"
%typemap(ktype) SWIGTYPE * "Long"
%typemap(kstype) SWIGTYPE * "$kotlinclassname?"

%typemap(jni) SWIGTYPE & "jlong"
%typemap(ktype) SWIGTYPE & "Long"
%typemap(kstype) SWIGTYPE & "$kotlinclassname"

%typemap(jni) SWIGTYPE && "jlong"
%typemap(ktype) SWIGTYPE && "Long"
%typemap(kstype) SWIGTYPE && "$kotlinclassname"

/* pointer to a class member */
%typemap(jni) SWIGTYPE (CLASS::*) "jstring"
%typemap(ktype) SWIGTYPE (CLASS::*) "String?"
%typemap(kstype) SWIGTYPE (CLASS::*) "$kotlinclassname?"

/* The following are the in, out, freearg, argout typemaps. These are the JNI code generating typemaps for converting from Java to C and visa versa. */

/* primitive types */
%typemap(in) bool
%{ $1 = $input ? true : false; %}

%typemap(directorout) bool
%{ $result = $input ? true : false; %}

%typemap(kdirectorin) bool "$jniinput"
%typemap(kdirectorout) bool "$kotlincall"

%typemap(in) char, 
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
             double
%{ $1 = ($1_ltype)$input; %}

%typemap(directorout) char, 
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
             double
%{ $result = ($1_ltype)$input; %}

%typemap(directorin, descriptor="Z") bool             "$input = (jboolean) $1;"
%typemap(directorin, descriptor="C") char             "$input = (jint) $1;"
%typemap(directorin, descriptor="B") signed char      "$input = (jbyte) $1;"
%typemap(directorin, descriptor="S") unsigned char    "$input = (jshort) $1;"
%typemap(directorin, descriptor="S") short            "$input = (jshort) $1;"
%typemap(directorin, descriptor="I") unsigned short   "$input = (jint) $1;"
%typemap(directorin, descriptor="I") int              "$input = (jint) $1;"
%typemap(directorin, descriptor="J") unsigned int     "$input = (jlong) $1;"
%typemap(directorin, descriptor="I") long             "$input = (jint) $1;"
%typemap(directorin, descriptor="J") unsigned long    "$input = (jlong) $1;"
%typemap(directorin, descriptor="J") long long        "$input = (jlong) $1;"
%typemap(directorin, descriptor="F") float            "$input = (jfloat) $1;"
%typemap(directorin, descriptor="D") double           "$input = (jdouble) $1;"

%typemap(kdirectorin) char, 
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
                         double
  "$jniinput"

%typemap(kdirectorout) char, 
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
                          double
  "$kotlincall"

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
  if (sz > 0) {
    $1 = ($1_type)(signed char)bae[0];
    for(i=1; i<sz; i++) {
      $1 = ($1 << 8) | ($1_type)(unsigned char)bae[i];
    }
  }
  JCALL3(ReleaseByteArrayElements, jenv, ba, bae, 0);
}

%typemap(directorout) unsigned long long { 
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
  $result = 0;
  if (sz > 0) {
    $result = ($1_type)(signed char)bae[0];
    for(i=1; i<sz; i++) {
      $result = ($result << 8) | ($1_type)(unsigned char)bae[i];
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
  JCALL1(DeleteLocalRef, jenv, ba);
  $result = bigint;
}

/* Convert to BigInteger (see out typemap) */
%typemap(directorin, descriptor="Ljava/math/BigInteger;", noblock=1) unsigned long long, const unsigned long long & {
{
  jbyteArray ba = JCALL1(NewByteArray, jenv, 9);
  jbyte* bae = JCALL2(GetByteArrayElements, jenv, ba, 0);
  jclass clazz = JCALL1(FindClass, jenv, "java/math/BigInteger");
  jmethodID mid = JCALL3(GetMethodID, jenv, clazz, "<init>", "([B)V");
  jobject bigint;
  int swig_i;

  bae[0] = 0;
  for(swig_i=1; swig_i<9; swig_i++ ) {
    bae[swig_i] = (jbyte)($1>>8*(8-swig_i));
  }

  JCALL3(ReleaseByteArrayElements, jenv, ba, bae, 0);
  bigint = JCALL3(NewObject, jenv, clazz, mid, ba);
  JCALL1(DeleteLocalRef, jenv, ba);
  $input = bigint;
}
Swig::LocalRefGuard $1_refguard(jenv, $input); }

%typemap(kdirectorin) unsigned long long "$jniinput"
%typemap(kdirectorout) unsigned long long "$kotlincall"

/* char * - treat as String */
%typemap(in, noblock=1) char * {
 $1 = 0;
  if ($input) {
    $1 = ($1_ltype)JCALL2(GetStringUTFChars, jenv, $input, 0);
    if (!$1) return $null;
  }
}

%typemap(directorout, noblock=1, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) char * {
  $1 = 0;
  if ($input) {
    $result = ($1_ltype)JCALL2(GetStringUTFChars, jenv, $input, 0);
    if (!$result) return $null;
  }
}

%typemap(directorin, descriptor="Ljava/lang/String;", noblock=1) char * {
  $input = 0;
  if ($1) {
    $input = JCALL1(NewStringUTF, jenv, (const char *)$1);
    if (!$input) return $null;
  }
  Swig::LocalRefGuard $1_refguard(jenv, $input);
}

%typemap(freearg, noblock=1) char * { if ($1) JCALL2(ReleaseStringUTFChars, jenv, $input, (const char *)$1); }
%typemap(out, noblock=1) char * { if ($1) $result = JCALL1(NewStringUTF, jenv, (const char *)$1); }
%typemap(kdirectorin) char * "$jniinput"
%typemap(kdirectorout) char * "$kotlincall"

/* char *& - treat as String */
%typemap(in, noblock=1) char *& ($*1_ltype temp = 0) {
 $1 = 0;
  if ($input) {
    temp = ($*1_ltype)JCALL2(GetStringUTFChars, jenv, $input, 0);
    if (!temp) return $null;
  }
  $1 = &temp;
}
%typemap(freearg, noblock=1) char *& { if ($1 && *$1) JCALL2(ReleaseStringUTFChars, jenv, $input, (const char *)*$1); }
%typemap(out, noblock=1) char *& { if (*$1) $result = JCALL1(NewStringUTF, jenv, (const char *)*$1); }

%typemap(out) void ""
%typemap(kdirectorin) void "$jniinput"
%typemap(kdirectorout) void "$kotlincall"
%typemap(directorin, descriptor="V") void ""

/* primitive types by reference */
%typemap(in) const bool & ($*1_ltype temp)
%{ temp = $input ? true : false; 
   $1 = &temp; %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const bool &
%{ static $*1_ltype temp;
   temp = $input ? true : false; 
   $result = &temp; %}

%typemap(kdirectorin) const bool & "$jniinput"
%typemap(kdirectorout) const bool & "$kotlincall"

%typemap(in) const char & ($*1_ltype temp), 
             const signed char & ($*1_ltype temp), 
             const unsigned char & ($*1_ltype temp), 
             const short & ($*1_ltype temp), 
             const unsigned short & ($*1_ltype temp), 
             const int & ($*1_ltype temp), 
             const unsigned int & ($*1_ltype temp), 
             const long & ($*1_ltype temp), 
             const unsigned long & ($*1_ltype temp), 
             const long long & ($*1_ltype temp), 
             const float & ($*1_ltype temp), 
             const double & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const char &,
             const signed char &,
             const unsigned char &,
             const short &,
             const unsigned short &,
             const int &,
             const unsigned int &,
             const long &,
             const unsigned long &,
             const long long &,
             const float &,
             const double &
%{ static $*1_ltype temp;
   temp = ($*1_ltype)$input; 
   $result = &temp; %}

%typemap(directorin, descriptor="Z") const bool &           "$input = (jboolean)$1;"
%typemap(directorin, descriptor="C") const char &           "$input = (jchar)$1;"
%typemap(directorin, descriptor="B") const signed char &    "$input = (jbyte)$1;"
%typemap(directorin, descriptor="S") const unsigned char &  "$input = (jshort)$1;"
%typemap(directorin, descriptor="S") const short &          "$input = (jshort)$1;"
%typemap(directorin, descriptor="I") const unsigned short & "$input = (jint)$1;"
%typemap(directorin, descriptor="I") const int &            "$input = (jint)$1;"
%typemap(directorin, descriptor="J") const unsigned int &   "$input = (jlong)$1;"
%typemap(directorin, descriptor="I") const long &           "$input = (jint)$1;"
%typemap(directorin, descriptor="J") const unsigned long &  "$input = (jlong)$1;"
%typemap(directorin, descriptor="J") const long long &      "$input = (jlong)$1;"
%typemap(directorin, descriptor="F") const float &          "$input = (jfloat)$1;"
%typemap(directorin, descriptor="D") const double &         "$input = (jdouble)$1;"

%typemap(kdirectorin) const char & ($*1_ltype temp), 
                         const signed char & ($*1_ltype temp), 
                         const unsigned char & ($*1_ltype temp), 
                         const short & ($*1_ltype temp), 
                         const unsigned short & ($*1_ltype temp), 
                         const int & ($*1_ltype temp), 
                         const unsigned int & ($*1_ltype temp), 
                         const long & ($*1_ltype temp), 
                         const unsigned long & ($*1_ltype temp), 
                         const long long & ($*1_ltype temp), 
                         const float & ($*1_ltype temp), 
                         const double & ($*1_ltype temp)
  "$jniinput"

%typemap(kdirectorout) const char & ($*1_ltype temp), 
                          const signed char & ($*1_ltype temp), 
                          const unsigned char & ($*1_ltype temp), 
                          const short & ($*1_ltype temp), 
                          const unsigned short & ($*1_ltype temp), 
                          const int & ($*1_ltype temp), 
                          const unsigned int & ($*1_ltype temp), 
                          const long & ($*1_ltype temp), 
                          const unsigned long & ($*1_ltype temp), 
                          const long long & ($*1_ltype temp), 
                          const float & ($*1_ltype temp), 
                          const double & ($*1_ltype temp)
  "$kotlincall"


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
%typemap(in) const unsigned long long & ($*1_ltype temp) { 
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
  if (sz > 0) {
    temp = ($*1_ltype)(signed char)bae[0];
    for(i=1; i<sz; i++) {
      temp = (temp << 8) | ($*1_ltype)(unsigned char)bae[i];
    }
  }
  JCALL3(ReleaseByteArrayElements, jenv, ba, bae, 0);
}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const unsigned long long & { 
  static $*1_ltype temp;
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
  $result = &temp;
  temp = 0;
  if (sz > 0) {
    temp = ($*1_ltype)(signed char)bae[0];
    for(i=1; i<sz; i++) {
      temp = (temp << 8) | ($*1_ltype)(unsigned char)bae[i];
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
  JCALL1(DeleteLocalRef, jenv, ba);
  $result = bigint;
}

%typemap(kdirectorin) const unsigned long long & "$jniinput"
%typemap(kdirectorout) const unsigned long long & "$kotlincall"

/* Default handling. Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE ($&1_type argp)
%{ argp = *($&1_ltype*)&$input; 
   if (!argp) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "Attempt to dereference null $1_type");
     return $null;
   }
   $1 = *argp; %}

%typemap(directorout) SWIGTYPE ($&1_type argp)
%{ argp = *($&1_ltype*)&$input; 
   if (!argp) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "Unexpected null return for type $1_type");
     return $null;
   }
   $result = *argp; %}

%typemap(out) SWIGTYPE 
#ifdef __cplusplus
%{ *($&1_ltype*)&$result = new $1_ltype($1); %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  *($&1_ltype*)&$result = $1ptr;
}
#endif

%typemap(directorin,descriptor="L$packagepath/$&kotlinclassname;") SWIGTYPE 
%{ $input = 0;
   *(($&1_ltype*)&$input) = new $1_ltype(SWIG_STD_MOVE($1)); %}
%typemap(kdirectorin) SWIGTYPE "$&kotlinclassname($jniinput, true)"
%typemap(kdirectorout) SWIGTYPE "$&kotlinclassname.getCPtr($kotlincall)"

/* Generic pointers and references */
%typemap(in) SWIGTYPE * %{ $1 = *($&1_ltype)&$input; %}
%typemap(in, fragment="SWIG_UnPackData") SWIGTYPE (CLASS::*) { 
  const char *temp = 0;
  if ($input) {
    temp = JCALL2(GetStringUTFChars, jenv, $input, 0);
    if (!temp) return $null;
  }
  SWIG_UnpackData(temp, (void *)&$1, sizeof($1));
}
%typemap(in) SWIGTYPE & %{ $1 = *($&1_ltype)&$input;
  if (!$1) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "$1_type is null");
    return $null;
  } %}
%typemap(in, fragment="<memory>") SWIGTYPE && (std::unique_ptr<$*1_ltype> rvrdeleter) %{ $1 = *($&1_ltype)&$input;
  if (!$1) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "$1_type is null");
    return $null;
  }
  rvrdeleter.reset($1); %}
%typemap(out) SWIGTYPE *
%{ *($&1_ltype)&$result = $1; %} 
%typemap(out, fragment="SWIG_PackData", noblock=1) SWIGTYPE (CLASS::*) {
  char buf[128];
  char *data = SWIG_PackData(buf, (void *)&$1, sizeof($1));
  *data = '\0';
  $result = JCALL1(NewStringUTF, jenv, buf);
}
%typemap(out) SWIGTYPE &
%{ *($&1_ltype)&$result = $1; %} 
%typemap(out) SWIGTYPE &&
%{ *($&1_ltype)&$result = $1; %} 

%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) SWIGTYPE *
%{ $result = *($&1_ltype)&$input; %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) SWIGTYPE (CLASS::*)
%{ $result = *($&1_ltype)&$input; %}

%typemap(directorin,descriptor="L$packagepath/$kotlinclassname;") SWIGTYPE *
%{ *(($&1_ltype)&$input) = ($1_ltype) $1; %}
%typemap(directorin,descriptor="L$packagepath/$kotlinclassname;") SWIGTYPE (CLASS::*)
%{ *(($&1_ltype)&$input) = ($1_ltype) $1; %}

%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) SWIGTYPE &
%{ if (!$input) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "Unexpected null return for type $1_type");
     return $null;
   }
   $result = *($&1_ltype)&$input; %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) SWIGTYPE &&
%{ if (!$input) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "Unexpected null return for type $1_type");
     return $null;
   }
   $result = *($&1_ltype)&$input; %}
%typemap(directorin,descriptor="L$packagepath/$kotlinclassname;") SWIGTYPE &
%{ *($&1_ltype)&$input = ($1_ltype) &$1; %}
%typemap(directorin,descriptor="L$packagepath/$kotlinclassname;") SWIGTYPE &&
%{ *($&1_ltype)&$input = ($1_ltype) &$1; %}

%typemap(kdirectorin) SWIGTYPE *, SWIGTYPE (CLASS::*) "if ($jniinput == 0L) null else $kotlinclassname($jniinput, false)"
%typemap(kdirectorin) SWIGTYPE & "$kotlinclassname($jniinput, false)"
%typemap(kdirectorin) SWIGTYPE && "$kotlinclassname($jniinput, false)"
%typemap(kdirectorout) SWIGTYPE *, SWIGTYPE (CLASS::*), SWIGTYPE &, SWIGTYPE && "$kotlinclassname.getCPtr($kotlincall)"

/* Default array handling */
%typemap(in) SWIGTYPE [] %{ $1 = *($&1_ltype)&$input; %}
%typemap(out) SWIGTYPE [] %{ *($&1_ltype)&$result = $1; %} 
%typemap(freearg) SWIGTYPE [ANY], SWIGTYPE [] ""

/* char arrays - treat as String */
%typemap(in, noblock=1) char[ANY], char[] {
  $1 = 0;
  if ($input) {
    $1 = ($1_ltype)JCALL2(GetStringUTFChars, jenv, $input, 0);
    if (!$1) return $null;
  }
}

%typemap(directorout, noblock=1) char[ANY], char[] {
  $1 = 0;
  if ($input) {
    $result = ($1_ltype)JCALL2(GetStringUTFChars, jenv, $input, 0);
    if (!$result) return $null;
  }
}

%typemap(directorin, descriptor="Ljava/lang/String;", noblock=1) char[ANY], char[] {
  $input = 0;
  if ($1) {
    $input = JCALL1(NewStringUTF, jenv, (const char *)$1);
    if (!$input) return $null;
  }
  Swig::LocalRefGuard $1_refguard(jenv, $input);
}

%typemap(argout) char[ANY], char[] ""
%typemap(freearg, noblock=1) char[ANY], char[] { if ($1) JCALL2(ReleaseStringUTFChars, jenv, $input, (const char *)$1); }
%typemap(out, noblock=1) char[ANY], char[] { if ($1) $result = JCALL1(NewStringUTF, jenv, (const char *)$1); }
%typemap(kdirectorin) char[ANY], char[] "$jniinput"
%typemap(kdirectorout) char[ANY], char[] "$kotlincall"

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

%typemap(directorout) jboolean,
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
%{ $result = $input; %}

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

%typemap(directorin,descriptor="Z")  jboolean       "$input = $1;"
%typemap(directorin,descriptor="C")  jchar          "$input = $1;"
%typemap(directorin,descriptor="B")  jbyte          "$input = $1;"
%typemap(directorin,descriptor="S")  jshort         "$input = $1;"
%typemap(directorin,descriptor="I")  jint           "$input = $1;"
%typemap(directorin,descriptor="J")  jlong          "$input = $1;"
%typemap(directorin,descriptor="F")  jfloat         "$input = $1;"
%typemap(directorin,descriptor="D")  jdouble        "$input = $1;"
%typemap(directorin,descriptor="Ljava/lang/String;")            jstring        "$input = $1;"
%typemap(directorin,descriptor="Ljava/lang/Object;",nouse="1")  jobject        "$input = $1;"
%typemap(directorin,descriptor="[Z")  jbooleanArray "$input = $1;"
%typemap(directorin,descriptor="[C")  jcharArray    "$input = $1;"
%typemap(directorin,descriptor="[B")  jbyteArray    "$input = $1;"
%typemap(directorin,descriptor="[S")  jshortArray   "$input = $1;"
%typemap(directorin,descriptor="[I")  jintArray     "$input = $1;"
%typemap(directorin,descriptor="[J")  jlongArray    "$input = $1;"
%typemap(directorin,descriptor="[F")  jfloatArray   "$input = $1;"
%typemap(directorin,descriptor="[D")  jdoubleArray  "$input = $1;"
%typemap(directorin,descriptor="[Ljava/lang/Object;",nouse="1") jobjectArray   "$input = $1;"

%typemap(kdirectorin) jboolean,
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
  "$jniinput"

%typemap(kdirectorout) jboolean,
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
  "$kotlincall"

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
    const long &
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
    unsigned long long,
    const unsigned long long &
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
    char *&,
    char[ANY],
    char []
    ""

%typecheck(SWIG_TYPECHECK_BOOL_ARRAY) /* Java boolean[] */
    jbooleanArray
    ""

%typecheck(SWIG_TYPECHECK_CHAR_ARRAY) /* Java char[] */
    jcharArray
    ""

%typecheck(SWIG_TYPECHECK_INT8_ARRAY) /* Java byte[] */
    jbyteArray
    ""

%typecheck(SWIG_TYPECHECK_INT16_ARRAY) /* Java short[] */
    jshortArray
    ""

%typecheck(SWIG_TYPECHECK_INT32_ARRAY) /* Java int[] */
    jintArray
    ""

%typecheck(SWIG_TYPECHECK_INT64_ARRAY) /* Java long[] */
    jlongArray
    ""

%typecheck(SWIG_TYPECHECK_FLOAT_ARRAY) /* Java float[] */
    jfloatArray
    ""

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY) /* Java double[] */
    jdoubleArray
    ""

%typecheck(SWIG_TYPECHECK_OBJECT_ARRAY) /* Java jobject[] */
    jobjectArray
    ""

%typecheck(SWIG_TYPECHECK_POINTER) /* Default */
    SWIGTYPE, 
    SWIGTYPE *, 
    SWIGTYPE &, 
    SWIGTYPE &&, 
    SWIGTYPE *const&, 
    SWIGTYPE [],
    SWIGTYPE (CLASS::*)
    ""


/* Exception handling */

%typemap(throws) int, 
                 long, 
                 short, 
                 unsigned int, 
                 unsigned long, 
                 unsigned short
%{ char error_msg[256];
   SWIG_snprintf(error_msg, sizeof(error_msg), "C++ $1_type exception thrown, value: %d", $1);
   SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, error_msg);
   return $null; %}

%typemap(throws) SWIGTYPE, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE *, SWIGTYPE [], SWIGTYPE [ANY]
%{ (void)$1;
   SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(throws) char *
%{ SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, $1);
   return $null; %}

/* For methods to raise/throw the original Java exception thrown in a director method */
%typemap(throws) Swig::DirectorException
%{  $1.throwException(jenv);
    return $null; %}

/* Java to C++ DirectorException should already be handled. Suppress warning and do nothing in the
   event a user specifies a global: %catches(Swig::DirectorException); */
%typemap(directorthrows) Swig::DirectorException ""

/* Typemaps for code generation in proxy classes and Java type wrapper classes */

/* The kin typemap is used for converting function parameter types from the type 
 * used in the proxy, module or type wrapper class to the type used in the JNI class. */
%typemap(kin) bool,               const bool &,
                 char,               const char &,
                 signed char,        const signed char &,
                 unsigned char,      const unsigned char &,
                 short,              const short &,
                 unsigned short,     const unsigned short &,
                 int,                const int &,
                 unsigned int,       const unsigned int &,
                 long,               const long &,
                 unsigned long,      const unsigned long &,
                 long long,          const long long &,
                 unsigned long long, const unsigned long long &,
                 float,              const float &,
                 double,             const double &
    "$kotlininput"
%typemap(kin) char *, char *&, char[ANY], char[] "$kotlininput"
%typemap(kin) jboolean,
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
    "$kotlininput"
%typemap(kin) SWIGTYPE "$&kotlinclassname.getCPtr($kotlininput)"
%typemap(kin) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] "$kotlinclassname.getCPtr($kotlininput)"
%typemap(kin) SWIGTYPE && "$kotlinclassname.swigRelease($kotlininput)"
%typemap(kin) SWIGTYPE (CLASS::*) "$kotlinclassname.getCMemberPtr($kotlininput)"

/* The kout typemap is used for converting function return types from the return type
 * used in the JNI class to the type returned by the proxy, module or type wrapper class. */
%typemap(kout) bool,               const bool &,
                  char,               const char &,
                  signed char,        const signed char &,
                  unsigned char,      const unsigned char &,
                  short,              const short &,
                  unsigned short,     const unsigned short &,
                  int,                const int &,
                  unsigned int,       const unsigned int &,
                  long,               const long &,
                  unsigned long,      const unsigned long &,
                  long long,          const long long &,
                  unsigned long long, const unsigned long long &,
                  float,              const float &,
                  double,             const double & {
    return $jnicall;
  }
%typemap(kout) char *, char *&, char[ANY], char[] {
    return $jnicall;
  }
%typemap(kout) jboolean,
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
                  jobjectArray {
    return $jnicall;
  }
%typemap(kout) void {
    $jnicall;
  }
%typemap(kout) SWIGTYPE {
    return $&kotlinclassname($jnicall, true);
  }
%typemap(kout) SWIGTYPE & {
    return $kotlinclassname($jnicall, $owner);
  }
%typemap(kout) SWIGTYPE && {
    return $kotlinclassname($jnicall, $owner);
  }
%typemap(kout) SWIGTYPE *, SWIGTYPE [] {
    val cPtr = $jnicall
    return if (cPtr == 0L) null else $kotlinclassname(cPtr, $owner)
  }
%typemap(kout) SWIGTYPE (CLASS::*) {
    val cMemberPtr = $jnicall
    return if (cMemberPtr == null) null else $kotlinclassname(cMemberPtr, $owner)
  }

/* Pointer reference typemaps */
%typemap(jni) SWIGTYPE *const& "jlong"
%typemap(ktype) SWIGTYPE *const& "Long"
%typemap(kstype) SWIGTYPE *const& "$*kotlinclassname?"
%typemap(kin) SWIGTYPE *const& "$*kotlinclassname.getCPtr($kotlininput)"
%typemap(kout) SWIGTYPE *const& {
    val cPtr = $jnicall
    return if (cPtr == 0L) null else $*kotlinclassname(cPtr, $owner)
  }
%typemap(in) SWIGTYPE *const& ($*1_ltype temp = 0)
%{ temp = *($1_ltype)&$input;
   $1 = ($1_ltype)&temp; %}
%typemap(out) SWIGTYPE *const&
%{ *($1_ltype)&$result = *$1; %} 
%typemap(directorin,descriptor="L$packagepath/$*kotlinclassname;") SWIGTYPE *const&
%{ *(($1_ltype)&$input) = ($*1_ltype) $1; %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) SWIGTYPE *const&
%{ static $*1_ltype swig_temp;
   swig_temp = *($1_ltype)&$input;
   $result = &swig_temp; %}
%typemap(kdirectorin) SWIGTYPE *const& "if ($jniinput == 0L) null else $*kotlinclassname($jniinput, false)"
%typemap(kdirectorout) SWIGTYPE *const& "$*kotlinclassname.getCPtr($kotlincall)"

/* Typemaps used for the generation of proxy and type wrapper class code.
   Proxy classes are open as Kotlin classes are final by default whereas the wrapped C++ classes
   can be derived from, in particular by the proxy classes of derived C++ classes. */
%typemap(kbase)             SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(kclassmodifiers)   SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) "open class"
%typemap(kcode)             SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(kimports)          SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(kinterfaces)       SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(kinterfacemodifiers) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) "interface"

/* kbody typemaps. The kbody typemap contains the instance members of a proxy or type
 * wrapper class and the kcompanion typemap contains the members of its companion object. */

%define SWIG_KOTLINBODY_PROXY(PTRCTOR_VISIBILITY, CPTR_VISIBILITY, TYPE...)
// Base proxy classes
%typemap(kbody) TYPE %{
  private var swigCPtr: Long
  protected var swigCMemOwn: Boolean

  PTRCTOR_VISIBILITY constructor(cPtr: Long, cMemoryOwn: Boolean) {
    swigCMemOwn = cMemoryOwn
    swigCPtr = cPtr
  }
%}

%typemap(kcompanion) TYPE %{
    CPTR_VISIBILITY fun getCPtr(obj: $kotlinclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }

    CPTR_VISIBILITY fun swigRelease(obj: $kotlinclassname?): Long {
      var ptr = 0L
      if (obj != null) {
        if (!obj.swigCMemOwn)
          throw RuntimeException("Cannot release ownership as memory is not owned")
        ptr = obj.swigCPtr
        obj.swigCMemOwn = false
        obj.delete()
      }
      return ptr
    }
%}

// Derived proxy classes
%typemap(kbody_derived) TYPE %{
  private var swigCPtr: Long

  PTRCTOR_VISIBILITY constructor(cPtr: Long, cMemoryOwn: Boolean) : super($imclassname.$kotlinclazznameSWIGUpcast(cPtr), cMemoryOwn) {
    swigCPtr = cPtr
  }
%}

%typemap(kcompanion_derived) TYPE %{
    CPTR_VISIBILITY fun getCPtr(obj: $kotlinclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }

    CPTR_VISIBILITY fun swigRelease(obj: $kotlinclassname?): Long {
      var ptr = 0L
      if (obj != null) {
        if (!obj.swigCMemOwn)
          throw RuntimeException("Cannot release ownership as memory is not owned")
        ptr = obj.swigCPtr
        obj.swigCMemOwn = false
        obj.delete()
      }
      return ptr
    }
%}
%enddef

%define SWIG_KOTLINBODY_TYPEWRAPPER(PTRCTOR_VISIBILITY, DEFAULTCTOR_VISIBILITY, CPTR_VISIBILITY, TYPE...)
// Typewrapper classes
%typemap(kbody) TYPE *, TYPE &, TYPE &&, TYPE [] %{
  private var swigCPtr: Long

  PTRCTOR_VISIBILITY constructor(cPtr: Long, @Suppress("UNUSED_PARAMETER") futureUse: Boolean) {
    swigCPtr = cPtr
  }

  DEFAULTCTOR_VISIBILITY constructor() {
    swigCPtr = 0L
  }
%}

%typemap(kcompanion) TYPE *, TYPE &, TYPE &&, TYPE [] %{
    CPTR_VISIBILITY fun getCPtr(obj: $kotlinclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }

    CPTR_VISIBILITY fun swigRelease(obj: $kotlinclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }
%}

%typemap(kbody) TYPE (CLASS::*) %{
  private var swigCMemberPtr: String?

  PTRCTOR_VISIBILITY constructor(cMemberPtr: String?, @Suppress("UNUSED_PARAMETER") futureUse: Boolean) {
    swigCMemberPtr = cMemberPtr
  }

  DEFAULTCTOR_VISIBILITY constructor() {
    swigCMemberPtr = null
  }
%}

%typemap(kcompanion) TYPE (CLASS::*) %{
    CPTR_VISIBILITY fun getCMemberPtr(obj: $kotlinclassname?): String? {
      return obj?.swigCMemberPtr
    }
%}
%enddef

/* Set the default kbody typemaps to use internal visibility, which in Kotlin gives access
   to the other generated classes in the same compilation module.
   Use the macros to change to public if using multiple modules. */
SWIG_KOTLINBODY_PROXY(internal, internal, SWIGTYPE)
SWIG_KOTLINBODY_TYPEWRAPPER(internal, protected, internal, SWIGTYPE)

/* Kotlin deliberately has no equivalent of Java finalizers, which have been deprecated for
   removal in modern JVMs anyway, so the kfinalize typemap is empty by default. Memory is
   reclaimed by calling delete() explicitly, or by registering with java.lang.ref.Cleaner. */
%typemap(kfinalize) SWIGTYPE ""

/*
 * Java constructor typemaps:
 *
 * The kconstruct typemap is inserted when a proxy class's constructor is generated.
 * This typemap allows control over what code is executed in the constructor as
 * well as specifying who owns the underlying C/C++ object. Normally, Java has
 * ownership and the underlying C/C++ object is deallocated when the Java object
 * is finalized (swigCMemOwn is true.) If swigCMemOwn is false, C/C++ is
 * ultimately responsible for deallocating the underlying object's memory.
 *
 * The SWIG_PROXY_CONSTRUCTOR macro defines the kconstruct typemap for a proxy
 * class for a particular TYPENAME. OWNERSHIP is passed as the value of
 * swigCMemOwn to the pointer constructor method.  WEAKREF determines which kind
 * of Java object reference will be used by the C++ director class (WeakGlobalRef
 * vs. GlobalRef.)
 *
 * The SWIG_DIRECTOR_OWNED macro sets the ownership of director-based proxy
 * classes and the weak reference flag to false, meaning that the underlying C++
 * object will be reclaimed by C++.
 */

%define SWIG_PROXY_CONSTRUCTOR(OWNERSHIP, WEAKREF, TYPENAME...)
%typemap(kconstruct,directorconnect="\n    $imclassname.$kotlinclazznamedirector_connect(this, swigCPtr, OWNERSHIP, WEAKREF)") TYPENAME ": this($imcall, OWNERSHIP) {$directorconnect\n  }"
%enddef

%define SWIG_DIRECTOR_OWNED(TYPENAME...)
SWIG_PROXY_CONSTRUCTOR(true, false, TYPENAME)
%enddef

// Set the default for SWIGTYPE: Java owns the C/C++ object.
SWIG_PROXY_CONSTRUCTOR(true, true, SWIGTYPE)

%typemap(kdestruct, methodname="delete", methodmodifiers="@Synchronized open", parameters="") SWIGTYPE {
    if (swigCPtr != 0L) {
      if (swigCMemOwn) {
        swigCMemOwn = false
        $jnicall
      }
      swigCPtr = 0L
    }
  }

%typemap(kdestruct_derived, methodname="delete", methodmodifiers="@Synchronized override", parameters="") SWIGTYPE {
    if (swigCPtr != 0L) {
      if (swigCMemOwn) {
        swigCMemOwn = false
        $jnicall
      }
      swigCPtr = 0L
    }
    super.delete()
  }

%typemap(directordisconnect, methodname="swigDirectorDisconnect") SWIGTYPE %{
  protected fun $methodname() {
    swigCMemOwn = false
    $jnicall
  }
%}

%typemap(directorowner_release, methodname="swigReleaseOwnership") SWIGTYPE %{
  fun $methodname() {
    swigCMemOwn = false
    $jnicall
  }
%}

%typemap(directorowner_take, methodname="swigTakeOwnership") SWIGTYPE %{
  fun $methodname() {
    swigCMemOwn = true
    $jnicall
  }
%}

/* Kotlin specific directives */
#define %kotlinconst(flag)            %feature("kotlin:const","flag")
#define %kotlinconstvalue(value)      %feature("kotlin:constvalue",value)
#define %kotlinenum(wrapapproach)     %feature("kotlin:enum","wrapapproach")
#define %kotlinmethodmodifiers      %feature("kotlin:methodmodifiers")
#define %kotlinexception(exceptionclasses) %feature("except",throws=exceptionclasses)
#define %nokotlinexception          %feature("except","0",throws="")
#define %clearkotlinexception       %feature("except","",throws="")
#define %proxycode                  %insert("proxycode")

%pragma(kotlin) jniclassclassmodifiers="object"
%pragma(kotlin) moduleclassmodifiers="object"
%pragma(kotlin) constantsmodifiers="object"

/* 64-bit architecture specific typemaps */
#if defined(SWIGWORDSIZE64)
%apply long long { long };
%apply unsigned long long { unsigned long };
%apply const long long & { const long & };
%apply const unsigned long long & { const unsigned long & };
#endif

/* size_t maps to Java 64-bit (signed) long type */
%apply unsigned int { size_t };
%apply const unsigned int & { const size_t & };

/* Array reference typemaps */
%apply SWIGTYPE & { SWIGTYPE ((&)[ANY]) }
%apply SWIGTYPE && { SWIGTYPE ((&&)[ANY]) }

/* const pointers */
%apply SWIGTYPE * { SWIGTYPE *const }
%apply SWIGTYPE (CLASS::*) { SWIGTYPE (CLASS::*const) }
%apply SWIGTYPE & { SWIGTYPE (CLASS::*const&) }

/* String & length */
%typemap(jni)     (const char *STRING, size_t LENGTH) "jbyteArray"
%typemap(ktype)   (const char *STRING, size_t LENGTH) "ByteArray?"
%typemap(kstype)  (const char *STRING, size_t LENGTH) "String?"
%typemap(kin)  (const char *STRING, size_t LENGTH) %{$kotlininput?.toByteArray()%}
%typemap(freearg) (const char *STRING, size_t LENGTH) ""
%typemap(in)      (const char *STRING, size_t LENGTH) {
  if ($input) {
    $1 = ($1_ltype) JCALL2(GetByteArrayElements, jenv, $input, 0);
    $2 = ($2_type) JCALL1(GetArrayLength, jenv, $input);
  } else {
    $1 = 0;
    $2 = 0;
  }
}
%typemap(argout)  (const char *STRING, size_t LENGTH) {
  if ($input) JCALL3(ReleaseByteArrayElements, jenv, $input, (jbyte *)$1, JNI_ABORT);
}
%typecheck(SWIG_TYPECHECK_STRING) (const char *STRING, size_t LENGTH) ""
%typemap(directorin, descriptor="Ljava/lang/String;", noblock=1) (const char *STRING, size_t LENGTH) {
  $input = 0;
  if ($1) {
    $input = JCALL1(NewByteArray, jenv, (jsize)$2);
    if (!$input) return $null;
    JCALL4(SetByteArrayRegion, jenv, $input, 0, (jsize)$2, (jbyte *)$1);
  }
  Swig::LocalRefGuard $1_refguard(jenv, $input);
}
%typemap(kdirectorin, descriptor="[B") (const char *STRING, size_t LENGTH) "if ($jniinput == null) null else String($jniinput)"
%apply (const char *STRING, size_t LENGTH) { (char *STRING, size_t LENGTH) }
/* Enable write-back for non-const version */
%typemap(argout)  (char *STRING, size_t LENGTH) {
  if ($input) JCALL3(ReleaseByteArrayElements, jenv, $input, (jbyte *)$1, 0);
}
%typemap(directorargout, noblock=1) (char *STRING, size_t LENGTH)
{ if ($input && $1) JCALL4(GetByteArrayRegion, jenv, $input, 0, (jsize)$2, (jbyte *)$1); }

%apply (char *STRING, size_t LENGTH) { (char *STRING, int LENGTH) }

/* Length & string reverse order typemap */

%typemap(jni)     (size_t LENGTH, const char *STRING) "jbyteArray"
%typemap(ktype)   (size_t LENGTH, const char *STRING) "ByteArray?"
%typemap(kstype)  (size_t LENGTH, const char *STRING) "String?"
%typemap(kin)  (size_t LENGTH, const char *STRING) %{$kotlininput?.toByteArray()%}
%typemap(freearg) (size_t LENGTH, const char *STRING) ""
%typemap(in)      (size_t LENGTH, const char *STRING) {
  if ($input) {
    $2 = ($2_ltype) JCALL2(GetByteArrayElements, jenv, $input, 0);
    $1 = ($1_type) JCALL1(GetArrayLength, jenv, $input);
  } else {
    $1 = 0;
    $2 = 0;
  }
}
%typemap(argout)  (size_t LENGTH, const char *STRING) {
  if ($input) JCALL3(ReleaseByteArrayElements, jenv, $input, (jbyte *)$2, JNI_ABORT);
}
%typecheck(SWIG_TYPECHECK_STRING) (size_t LENGTH, const char *STRING) ""
%typemap(directorin, descriptor="Ljava/lang/String;", noblock=1) (size_t LENGTH, const char *STRING) {
  $input = 0;
  if ($2) {
    $input = JCALL1(NewByteArray, jenv, (jsize)$1);
    if (!$input) return $null;
    JCALL4(SetByteArrayRegion, jenv, $input, 0, (jsize)$1, (jbyte *)$2);
  }
  Swig::LocalRefGuard $2_refguard(jenv, $input);
}
%typemap(kdirectorin, descriptor="[B") (size_t LENGTH, const char *STRING) "if ($jniinput == null) null else String($jniinput)"
%apply (size_t LENGTH, const char *STRING) { (size_t LENGTH, char *STRING) }
/* Enable write-back for non-const version */
%typemap(argout)  (size_t LENGTH, char *STRING) {
  if ($input) JCALL3(ReleaseByteArrayElements, jenv, $input, (jbyte *)$2, 0);
}
%typemap(directorargout, noblock=1) (size_t LENGTH, char *STRING)
{ if ($input && $2) JCALL4(GetByteArrayRegion, jenv, $input, 0, (jsize)$1, (jbyte *)$2); }

%apply (size_t LENGTH, char *STRING) { (int LENGTH, char *STRING) }

/* kotlin keywords */
%include <kotlinkw.swg>

// Default enum handling
%include <enumtypesafe.swg>

