
/* JNI function calls require different calling conventions for C and C++. These JCALL macros are used so 
 * that the same typemaps can be used for generating code for both C and C++. The SWIG preprocessor can expand
 * the macros thereby generating the correct calling convention. It is thus essential that all typemaps that
 * use the macros are not within %{ %} brackets as they won't be run through the SWIG preprocessor. */
#ifdef __cplusplus
#   define JCALL0(func, jenv) jenv->func()
#   define JCALL1(func, jenv, ar1) jenv->func(ar1)
#   define JCALL2(func, jenv, ar1, ar2) jenv->func(ar1, ar2)
#   define JCALL3(func, jenv, ar1, ar2, ar3) jenv->func(ar1, ar2, ar3)
#   define JCALL4(func, jenv, ar1, ar2, ar3, ar4) jenv->func(ar1, ar2, ar3, ar4)
#else
#   define JCALL0(func, jenv) (*jenv)->func(jenv)
#   define JCALL1(func, jenv, ar1) (*jenv)->func(jenv, ar1)
#   define JCALL2(func, jenv, ar1, ar2) (*jenv)->func(jenv, ar1, ar2)
#   define JCALL3(func, jenv, ar1, ar2, ar3) (*jenv)->func(jenv, ar1, ar2, ar3)
#   define JCALL4(func, jenv, ar1, ar2, ar3, ar4) (*jenv)->func(jenv, ar1, ar2, ar3, ar4)
#endif

%insert(runtime) %{
#if defined(__GNUC__)
    typedef long long __int64; /*For gcc on Windows */
#endif
#include <jni.h>
#include <stdlib.h>
#include <string.h>
%}

%insert(runtime) %{
/* Support for throwing Java exceptions */
typedef enum {
  SWIG_JavaOutOfMemoryError = 1, 
  SWIG_JavaIOException, 
  SWIG_JavaRuntimeException, 
  SWIG_JavaIndexOutOfBoundsException,
  SWIG_JavaArithmeticException,
  SWIG_JavaIllegalArgumentException,
  SWIG_JavaNullPointerException,
  SWIG_JavaUnknownError
} SWIG_JavaExceptionCodes;

typedef struct {
  SWIG_JavaExceptionCodes code;
  const char *java_exception;
} SWIG_JavaExceptions_t;

#if defined(SWIG_NOINCLUDE)
void SWIG_JavaThrowException(JNIEnv *jenv, SWIG_JavaExceptionCodes code, const char *msg);
#else
%}
%insert(runtime) {
void SWIG_JavaThrowException(JNIEnv *jenv, SWIG_JavaExceptionCodes code, const char *msg) {
  jclass excep;
  static const SWIG_JavaExceptions_t java_exceptions[] = {
    { SWIG_JavaOutOfMemoryError, "java/lang/OutOfMemoryError" },
    { SWIG_JavaIOException, "java/io/IOException" },
    { SWIG_JavaRuntimeException, "java/lang/RuntimeException" },
    { SWIG_JavaIndexOutOfBoundsException, "java/lang/IndexOutOfBoundsException" },
    { SWIG_JavaArithmeticException, "java/lang/ArithmeticException" },
    { SWIG_JavaIllegalArgumentException, "java/lang/IllegalArgumentException" },
    { SWIG_JavaNullPointerException, "java/lang/NullPointerException" },
    { SWIG_JavaUnknownError,  "java/lang/UnknownError" },
    { (SWIG_JavaExceptionCodes)0,  "java/lang/UnknownError" } };
  const SWIG_JavaExceptions_t *except_ptr = java_exceptions;

  while (except_ptr->code != code && except_ptr->code)
    except_ptr++;

  JCALL0(ExceptionClear, jenv);
  excep = JCALL1(FindClass, jenv, except_ptr->java_exception);
  if (excep)
    JCALL2(ThrowNew, jenv, excep, msg);
}
}
%insert(runtime) %{
#endif
%}

/* Array support is a combination of SWIG macros and functions in order to reduce code bloat and 
 * aid maintainability. The SWIG preprocessor expands the macros into functions for inclusion in
 * the generated code. */
%define JAVA_ARRAYS_DECL(CTYPE, JNITYPE, JAVATYPE, JFUNCNAME)
%{
int SWIG_JavaArrayIn##JFUNCNAME (JNIEnv *jenv, JNITYPE **jarr, CTYPE **carr, JNITYPE##Array input);
void SWIG_JavaArrayArgout##JFUNCNAME (JNIEnv *jenv, JNITYPE *jarr, CTYPE *carr, JNITYPE##Array input);
JNITYPE##Array SWIG_JavaArrayOut##JFUNCNAME (JNIEnv *jenv, CTYPE *result, jsize sz);
%}
%enddef

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
#if __cplusplus
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
  jsize sz;
  sz = JCALL1(GetArrayLength, jenv, input);
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

