#if defined(__GNUC__)
    typedef long long __int64; /*For gcc on Windows */
#endif
#include <jni.h>
#include <stdlib.h>

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

#ifdef SWIG_NOINCLUDE
void SWIG_JavaThrowException(JNIEnv *jenv, SWIG_JavaExceptionCodes code, const char *msg);
int SWIG_JavaArrayInChar(JNIEnv *jenv, jbyte **jarr, char **carr, jbyteArray input);
void SWIG_JavaArrayFreeargChar(JNIEnv *jenv, jbyte *jarr, char *carr, jbyteArray input);
jbyteArray SWIG_JavaArrayOutChar(JNIEnv *jenv, char *result, jsize sz);
int SWIG_JavaArrayInSchar(JNIEnv *jenv, jbyte **jarr, signed char **carr, jbyteArray input);
void SWIG_JavaArrayFreeargSchar(JNIEnv *jenv, jbyte *jarr, signed char *carr, jbyteArray input);
jbyteArray SWIG_JavaArrayOutSchar(JNIEnv *jenv, signed char *result, jsize sz);
int SWIG_JavaArrayInUchar(JNIEnv *jenv, jshort **jarr, unsigned char **carr, jshortArray input);
void SWIG_JavaArrayFreeargUchar(JNIEnv *jenv, jshort *jarr, unsigned char *carr, jshortArray input);
jshortArray SWIG_JavaArrayOutUchar(JNIEnv *jenv, unsigned char *result, jsize sz);
int SWIG_JavaArrayInShort(JNIEnv *jenv, jshort **jarr, short **carr, jshortArray input);
void SWIG_JavaArrayFreeargShort(JNIEnv *jenv, jshort *jarr, short *carr, jshortArray input);
jshortArray SWIG_JavaArrayOutShort(JNIEnv *jenv, short *result, jsize sz);
int SWIG_JavaArrayInUshort(JNIEnv *jenv, jint **jarr, unsigned short **carr, jintArray input);
void SWIG_JavaArrayFreeargUshort(JNIEnv *jenv, jint *jarr, unsigned short *carr, jintArray input);
jintArray SWIG_JavaArrayOutUshort(JNIEnv *jenv, unsigned short *result, jsize sz);
int SWIG_JavaArrayInInt(JNIEnv *jenv, jint **jarr, int **carr, jintArray input);
void SWIG_JavaArrayFreeargInt(JNIEnv *jenv, jint *jarr, int *carr, jintArray input);
jintArray SWIG_JavaArrayOutInt(JNIEnv *jenv, int *result, jsize sz);
int SWIG_JavaArrayInUint(JNIEnv *jenv, jlong **jarr, unsigned int **carr, jlongArray input);
void SWIG_JavaArrayFreeargUint(JNIEnv *jenv, jlong *jarr, unsigned int *carr, jlongArray input);
jlongArray SWIG_JavaArrayOutUint(JNIEnv *jenv, unsigned int *result, jsize sz);
int SWIG_JavaArrayInLong(JNIEnv *jenv, jint **jarr, long **carr, jintArray input);
void SWIG_JavaArrayFreeargLong(JNIEnv *jenv, jint *jarr, long *carr, jintArray input);
jintArray SWIG_JavaArrayOutLong(JNIEnv *jenv, long *result, jsize sz);
int SWIG_JavaArrayInUlong(JNIEnv *jenv, jlong **jarr, unsigned long **carr, jlongArray input);
void SWIG_JavaArrayFreeargUlong(JNIEnv *jenv, jlong *jarr, unsigned long *carr, jlongArray input);
jlongArray SWIG_JavaArrayOutUlong(JNIEnv *jenv, unsigned long *result, jsize sz);
int SWIG_JavaArrayInLonglong(JNIEnv *jenv, jlong **jarr, jlong **carr, jlongArray input);
void SWIG_JavaArrayFreeargLonglong(JNIEnv *jenv, jlong *jarr, jlong *carr, jlongArray input);
jlongArray SWIG_JavaArrayOutLonglong(JNIEnv *jenv, jlong *result, jsize sz);
int SWIG_JavaArrayInFloat(JNIEnv *jenv, jfloat **jarr, float **carr, jfloatArray input);
void SWIG_JavaArrayFreeargFloat(JNIEnv *jenv, jfloat *jarr, float *carr, jfloatArray input);
jfloatArray SWIG_JavaArrayOutFloat(JNIEnv *jenv, float *result, jsize sz);
int SWIG_JavaArrayInDouble(JNIEnv *jenv, jdouble **jarr, double **carr, jdoubleArray input);
void SWIG_JavaArrayFreeargDouble(JNIEnv *jenv, jdouble *jarr, double *carr, jdoubleArray input);
jdoubleArray SWIG_JavaArrayOutDouble(JNIEnv *jenv, double *result, jsize sz);
#ifdef __cplusplus
int SWIG_JavaArrayInBool(JNIEnv *jenv, jboolean **jarr, bool **carr, jbooleanArray input);
void SWIG_JavaArrayFreeargBool(JNIEnv *jenv, jboolean *jarr, bool *carr, jbooleanArray input);
jbooleanArray SWIG_JavaArrayOutBool(JNIEnv *jenv, bool *result, jsize sz);
#endif

#else
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

/* Array support is a combination of macros and functions. It may initially do your head in following 
 * it but it avoids code bloat and aids maintainability. */
#define SWIG_JavaArrayIn(CTYPE, GETARRAYELEMENTS) \
  int i; \
  jsize sz; \
  if (!input) { \
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null array"); \
    return 0; \
  } \
  sz = JCALL1(GetArrayLength, jenv, input); \
  *jarr = JCALL2(GETARRAYELEMENTS, jenv, input, 0); \
  if (!*jarr) \
    return 0; \
  *carr = (CTYPE*) calloc(sz, sizeof(CTYPE)); \
  if (!*carr) { \
    SWIG_JavaThrowException(jenv, SWIG_JavaOutOfMemoryError, "calloc failed"); \
    return 0; \
  } \
  for (i=0; i<sz; i++) \
    (*carr)[i] = (CTYPE)(*jarr)[i]; \
  return 1;

#define SWIG_JavaArrayFreearg(JTYPE, RELEASEARRAYELEMENTS) \
  int i; \
  jsize sz; \
  sz = JCALL1(GetArrayLength, jenv, input); \
  for (i=0; i<sz; i++) \
    jarr[i] = (JTYPE)carr[i]; \
  JCALL3(RELEASEARRAYELEMENTS, jenv, input, jarr, 0); \
  free(carr);

#define SWIG_JavaArrayOut(JTYPE, JARRAY, NEWARRAY, GETARRAYELEMENTS, RELEASEARRAYELEMENTS) \
  JTYPE *arr; \
  int i; \
  JARRAY jresult = JCALL1(NEWARRAY, jenv, sz); \
  if (!jresult) \
    return NULL; \
  arr = JCALL2(GETARRAYELEMENTS, jenv, jresult, 0); \
  if (!arr) \
    return NULL; \
  for (i=0; i<sz; i++) \
    arr[i] = (JTYPE)result[i]; \
  JCALL3(RELEASEARRAYELEMENTS, jenv, jresult, arr, 0); \
  return jresult;

/* char[] support */
int SWIG_JavaArrayInChar(JNIEnv *jenv, jbyte **jarr, char **carr, jbyteArray input) {
  SWIG_JavaArrayIn(char, GetByteArrayElements)
}
void SWIG_JavaArrayFreeargChar(JNIEnv *jenv, jbyte *jarr, char *carr, jbyteArray input) {
  SWIG_JavaArrayFreearg(jbyte, ReleaseByteArrayElements)
}
jbyteArray SWIG_JavaArrayOutChar(JNIEnv *jenv, char *result, jsize sz) {
  SWIG_JavaArrayOut(jbyte, jbyteArray, NewByteArray, GetByteArrayElements, ReleaseByteArrayElements)
}

/* signed char[] support */
int SWIG_JavaArrayInSchar(JNIEnv *jenv, jbyte **jarr, signed char **carr, jbyteArray input) {
  SWIG_JavaArrayIn(signed char, GetByteArrayElements)
}
void SWIG_JavaArrayFreeargSchar(JNIEnv *jenv, jbyte *jarr, signed char *carr, jbyteArray input) {
  SWIG_JavaArrayFreearg(jbyte, ReleaseByteArrayElements)
}
jbyteArray SWIG_JavaArrayOutSchar(JNIEnv *jenv, signed char *result, jsize sz) {
  SWIG_JavaArrayOut(jbyte, jbyteArray, NewByteArray, GetByteArrayElements, ReleaseByteArrayElements)
}

/* unsigned char[] support */
int SWIG_JavaArrayInUchar(JNIEnv *jenv, jshort **jarr, unsigned char **carr, jshortArray input) {
  SWIG_JavaArrayIn(unsigned char, GetShortArrayElements)
}
void SWIG_JavaArrayFreeargUchar(JNIEnv *jenv, jshort *jarr, unsigned char *carr, jshortArray input) {
  SWIG_JavaArrayFreearg(jshort, ReleaseShortArrayElements)
}
jshortArray SWIG_JavaArrayOutUchar(JNIEnv *jenv, unsigned char *result, jsize sz) {
  SWIG_JavaArrayOut(jshort, jshortArray, NewShortArray, GetShortArrayElements, ReleaseShortArrayElements)
}

/* short[] support */
int SWIG_JavaArrayInShort(JNIEnv *jenv, jshort **jarr, short **carr, jshortArray input) {
  SWIG_JavaArrayIn(short, GetShortArrayElements)
}
void SWIG_JavaArrayFreeargShort(JNIEnv *jenv, jshort *jarr, short *carr, jshortArray input) {
  SWIG_JavaArrayFreearg(jshort, ReleaseShortArrayElements)
}
jshortArray SWIG_JavaArrayOutShort(JNIEnv *jenv, short *result, jsize sz) {
  SWIG_JavaArrayOut(jshort, jshortArray, NewShortArray, GetShortArrayElements, ReleaseShortArrayElements)
}

/* unsigned short[] support */
int SWIG_JavaArrayInUshort(JNIEnv *jenv, jint **jarr, unsigned short **carr, jintArray input) {
  SWIG_JavaArrayIn(unsigned short, GetIntArrayElements)
}
void SWIG_JavaArrayFreeargUshort(JNIEnv *jenv, jint *jarr, unsigned short *carr, jintArray input) {
  SWIG_JavaArrayFreearg(jint, ReleaseIntArrayElements)
}
jintArray SWIG_JavaArrayOutUshort(JNIEnv *jenv, unsigned short *result, jsize sz) {
  SWIG_JavaArrayOut(jint, jintArray, NewIntArray, GetIntArrayElements, ReleaseIntArrayElements)
}

/* int[] support */
int SWIG_JavaArrayInInt(JNIEnv *jenv, jint **jarr, int **carr, jintArray input) {
  SWIG_JavaArrayIn(int, GetIntArrayElements)
}
void SWIG_JavaArrayFreeargInt(JNIEnv *jenv, jint *jarr, int *carr, jintArray input) {
  SWIG_JavaArrayFreearg(jint, ReleaseIntArrayElements)
}
jintArray SWIG_JavaArrayOutInt(JNIEnv *jenv, int *result, jsize sz) {
  SWIG_JavaArrayOut(jint, jintArray, NewIntArray, GetIntArrayElements, ReleaseIntArrayElements)
}

/* unsigned int[] support */
int SWIG_JavaArrayInUint(JNIEnv *jenv, jlong **jarr, unsigned int **carr, jlongArray input) {
  SWIG_JavaArrayIn(unsigned int, GetLongArrayElements)
}
void SWIG_JavaArrayFreeargUint(JNIEnv *jenv, jlong *jarr, unsigned int *carr, jlongArray input) {
  SWIG_JavaArrayFreearg(jlong, ReleaseLongArrayElements)
}
jlongArray SWIG_JavaArrayOutUint(JNIEnv *jenv, unsigned int *result, jsize sz) {
  SWIG_JavaArrayOut(jlong, jlongArray, NewLongArray, GetLongArrayElements, ReleaseLongArrayElements)
}

/* long[] support */
int SWIG_JavaArrayInLong(JNIEnv *jenv, jint **jarr, long **carr, jintArray input) {
  SWIG_JavaArrayIn(long, GetIntArrayElements)
}
void SWIG_JavaArrayFreeargLong(JNIEnv *jenv, jint *jarr, long *carr, jintArray input) {
  SWIG_JavaArrayFreearg(jint, ReleaseIntArrayElements)
}
jintArray SWIG_JavaArrayOutLong(JNIEnv *jenv, long *result, jsize sz) {
  SWIG_JavaArrayOut(jint, jintArray, NewIntArray, GetIntArrayElements, ReleaseIntArrayElements)
}

/* unsigned long[] support */
int SWIG_JavaArrayInUlong(JNIEnv *jenv, jlong **jarr, unsigned long **carr, jlongArray input) {
  SWIG_JavaArrayIn(unsigned long, GetLongArrayElements)
}
void SWIG_JavaArrayFreeargUlong(JNIEnv *jenv, jlong *jarr, unsigned long *carr, jlongArray input) {
  SWIG_JavaArrayFreearg(jlong, ReleaseLongArrayElements)
}
jlongArray SWIG_JavaArrayOutUlong(JNIEnv *jenv, unsigned long *result, jsize sz) {
  SWIG_JavaArrayOut(jlong, jlongArray, NewLongArray, GetLongArrayElements, ReleaseLongArrayElements)
}

/* long long[] support */
int SWIG_JavaArrayInLonglong(JNIEnv *jenv, jlong **jarr, jlong **carr, jlongArray input) {
  SWIG_JavaArrayIn(jlong, GetLongArrayElements)
}
void SWIG_JavaArrayFreeargLonglong(JNIEnv *jenv, jlong *jarr, jlong *carr, jlongArray input) {
  SWIG_JavaArrayFreearg(jlong, ReleaseLongArrayElements)
}
jlongArray SWIG_JavaArrayOutLonglong(JNIEnv *jenv, jlong *result, jsize sz) {
  SWIG_JavaArrayOut(jlong, jlongArray, NewLongArray, GetLongArrayElements, ReleaseLongArrayElements)
}

/* float[] support */
int SWIG_JavaArrayInFloat(JNIEnv *jenv, jfloat **jarr, float **carr, jfloatArray input) {
  SWIG_JavaArrayIn(float, GetFloatArrayElements)
}
void SWIG_JavaArrayFreeargFloat(JNIEnv *jenv, jfloat *jarr, float *carr, jfloatArray input) {
  SWIG_JavaArrayFreearg(jfloat, ReleaseFloatArrayElements)
}
jfloatArray SWIG_JavaArrayOutFloat(JNIEnv *jenv, float *result, jsize sz) {
  SWIG_JavaArrayOut(jfloat, jfloatArray, NewFloatArray, GetFloatArrayElements, ReleaseFloatArrayElements)
}

/* double[] support */
int SWIG_JavaArrayInDouble(JNIEnv *jenv, jdouble **jarr, double **carr, jdoubleArray input) {
  SWIG_JavaArrayIn(double, GetDoubleArrayElements)
}
void SWIG_JavaArrayFreeargDouble(JNIEnv *jenv, jdouble *jarr, double *carr, jdoubleArray input) {
  SWIG_JavaArrayFreearg(jdouble, ReleaseDoubleArrayElements)
}
jdoubleArray SWIG_JavaArrayOutDouble(JNIEnv *jenv, double *result, jsize sz) {
  SWIG_JavaArrayOut(jdouble, jdoubleArray, NewDoubleArray, GetDoubleArrayElements, ReleaseDoubleArrayElements)
}

#ifdef __cplusplus
/* bool[] support */
int SWIG_JavaArrayInBool(JNIEnv *jenv, jboolean **jarr, bool **carr, jbooleanArray input) {
  SWIG_JavaArrayIn(bool, GetBooleanArrayElements)
}
void SWIG_JavaArrayFreeargBool(JNIEnv *jenv, jboolean *jarr, bool *carr, jbooleanArray input) {
  SWIG_JavaArrayFreearg(jboolean, ReleaseBooleanArrayElements)
}
jbooleanArray SWIG_JavaArrayOutBool(JNIEnv *jenv, bool *result, jsize sz) {
  SWIG_JavaArrayOut(jboolean, jbooleanArray, NewBooleanArray, GetBooleanArrayElements, ReleaseBooleanArrayElements)
}
#endif

#endif /* SWIG_NOINCLUDE */

