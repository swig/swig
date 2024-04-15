/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

/* ------------------------------------------------------------
 * Typemap for passing bytes with length
 * ------------------------------------------------------------ */

/* String & length */
%typemap(jni)     (const void *BYTES, size_t LENGTH) "jbyteArray"
%typemap(jtype)   (const void *BYTES, size_t LENGTH) "byte[]"
%typemap(jstype)  (const void *BYTES, size_t LENGTH) "byte[]"
%typemap(javain)  (const void *BYTES, size_t LENGTH) "$javainput"
%typemap(freearg) (const void *BYTES, size_t LENGTH) ""
%typemap(in)      (const void *BYTES, size_t LENGTH) {
  if ($input) {
    $1 = ($1_ltype) JCALL2(GetByteArrayElements, jenv, $input, 0);
    $2 = ($2_type) JCALL1(GetArrayLength, jenv, $input);
  } else {
    $1 = 0;
    $2 = 0;
  }
}
%typemap(argout)  (const void *BYTES, size_t LENGTH) {
  if ($input) JCALL3(ReleaseByteArrayElements, jenv, $input, (jbyte *)$1, JNI_ABORT);
}
%typemap(directorin, descriptor="[B", noblock=1) (const void *BYTES, size_t LENGTH) {
  $input = 0;
  if ($1) {
    $input = JCALL1(NewByteArray, jenv, (jsize)$2);
    if (!$input) return $null;
    JCALL4(SetByteArrayRegion, jenv, $input, 0, (jsize)$2, (jbyte *)$1);
  }
  Swig::LocalRefGuard $1_refguard(jenv, $input);
}
%typemap(javadirectorin, descriptor="[B") (const void *BYTES, size_t LENGTH) "$jniinput"
%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }
/* Enable write-back for non-const version */
%typemap(argout)  (void *BYTES, size_t LENGTH) {
  if ($input) JCALL3(ReleaseByteArrayElements, jenv, $input, (jbyte *)$1, 0);
}
%typemap(directorargout, noblock=1) (void *BYTES, size_t LENGTH)
{ if ($input && $1) JCALL4(GetByteArrayRegion, jenv, $input, 0, (jsize)$2, (jbyte *)$1); }

%include <typemaps/cdata_begin.swg>

%typemap(jni) SWIGCDATA "jbyteArray"
%typemap(jtype) SWIGCDATA "byte[]"
%typemap(jstype) SWIGCDATA "byte[]"
%fragment("SWIG_JavaArrayOutCDATA", "header") {
static jbyteArray SWIG_JavaArrayOutCDATA(JNIEnv *jenv, char *result, jsize sz) {
  jbyteArray jresult;
  jbyte *arr;
  int i;
  jresult = JCALL1(NewByteArray, jenv, sz);
  if (!jresult) {
    return SWIG_NULLPTR;
  }
  arr = JCALL2(GetByteArrayElements, jenv, jresult, 0);
  if (!arr) {
    return SWIG_NULLPTR;
  }
  for (i=0; i<sz; i++) {
    arr[i] = (jbyte)result[i];
  }
  JCALL3(ReleaseByteArrayElements, jenv, jresult, arr, 0);
  return jresult;
}
}
%typemap(out, fragment="SWIG_JavaArrayOutCDATA") SWIGCDATA
%{$result = SWIG_JavaArrayOutCDATA(jenv, (char *)$1.data, $1.len); %}
%typemap(javaout) SWIGCDATA {
    return $jnicall;
  }

%include <typemaps/cdata_end.swg>
