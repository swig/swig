/* -------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------- */

%typemap(jni) (int ARGC, char **ARGV) "jobjectArray"
%typemap(jtype) (int ARGC, char **ARGV) "String[]"
%typemap(jstype) (int ARGC, char **ARGV) "String[]"

%typemap(in) (int ARGC, char **ARGV) {
  $1_ltype i, len;
  if ($input == (jobjectArray)0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null array");
    SWIG_fail;
  }
  len = ($1_ltype)JCALL1(GetArrayLength, jenv, $input);
  if (len < 0) {
    SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "array length negative");
    SWIG_fail;
  }
  $2 = ($2_ltype) malloc((len+1)*sizeof($*2_ltype));
  if ($2 == NULL) {
    SWIG_JavaThrowException(jenv, SWIG_JavaOutOfMemoryError, "memory allocation failed");
    SWIG_fail;
  }
  $1 = len;
  for (i = 0; i < len; i++) {
    jstring j_string = (jstring)JCALL2(GetObjectArrayElement, jenv, $input, (jsize)i);
    const char *c_string = JCALL2(GetStringUTFChars, jenv, j_string, 0);
    $2[i] = ($*2_ltype)c_string;
  }
  $2[i] = NULL;
}

%typemap(freearg) (int ARGC, char **ARGV) {
  free((void *)$2);
}
