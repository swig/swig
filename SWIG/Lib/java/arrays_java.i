/* arrays_java.i
 * These typemaps give more natural support for arrays. The typemaps are inefficient
 * as there is a lot of copying of the array values whenever the array is passe to C++ 
 * from Java and visa versa.
 */

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
    return $javaclassname.cArrayWrap($nativemethod, $owner);
  }

%typemap(in) ARRAYSOFCLASSES[ANY] (jlong *jarr, jsize sz)
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
    return $nativemethod;
  }

%typemap(in) ARRAYSOFENUMS[ANY] (jint *jarr)
%{ if (!SWIG_JavaArrayInInt(jenv, &jarr, (int**)&$1, $input)) return $null; %}
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

