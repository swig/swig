/*
 * SWIG Typemap library for Java
 * Various useful typemaps.
 *
*/
%typemap(jtype) char *STRING "String"
%typemap(in) char *STRING {
  $target = JCALL2(GetStringUTFChars, jenv, $source, 0);
}

%typemap(argout) char *STRING {
  JCALL2(ReleaseStringUTFChars, jenv, $source, $target);
}

%typemap(out) char *STRING {
  $target = (jarray) JCALL1(NewStringUTF, jenv, $source);
}

%typemap(jtype) char **STRING_IN "String[]"
%typemap(jni) char **STRING_IN "jobjectArray"
%typemap(in) char **STRING_IN {
  int i;
  jsize sz = JCALL1(GetArrayLength, jenv, $source);
  $target = (char **) malloc((sz+1) * sizeof(char *));
  for(i=0; i<sz; i++) {
    jstring js;
    char *cs;

    js = (jstring) JCALL2(GetObjectArrayElement, jenv, $source, i);
    cs = (char *) JCALL2(GetStringUTFChars, jenv, js, 0);
    $target[i] = cs;
  }
  $target[sz] = '\0';
}

%typemap(argout) char **STRING_IN {
  /* should release strings obtained from GetStringUTFChars */
  free($target);
}

/* result must be a null terminated string */
%typemap(jtype) char **STRING_OUT "String[]"
%typemap(jni) char **STRING_OUT "jobjectArray"
%typemap(in) char **STRING_OUT (char *s) {
  $target = &s;
}
%typemap(argout) char **STRING_OUT {
  if($target != NULL)
    JCALL3(SetObjectArrayElement, jenv, $source, 0, JCALL1(NewStringUTF, jenv, *$target));
}

/* a NULL terminated array of char* */
%typemap(jtype) char **STRING_RET "String[]"
%typemap(jni) char **STRING_RET "jarray"
%typemap(out) char **STRING_RET {
  if($source != NULL) {
    char **p = $source;
    jsize size = 0;
    int i = 0;
    jclass strClass;
    
    while (*p++) size++; /* determine size */
    strClass = JCALL1(FindClass, jenv, "java/lang/String");
    $target = JCALL3(NewObjectArray, jenv, size, strClass, NULL);
    p = $source;
    while (*p) {
      jstring js = JCALL1(NewStringUTF, jenv, *p);
      JCALL3(SetObjectArrayElement, jenv, $target, i++, js);
      p++;
    }
  }
}

%typemap(jni) int *INT_OUT "jintArray"
%typemap(jtype) int *INT_OUT "int[]"
%typemap(in) int *INT_OUT (int i) {
   $target = (int *)&i;
}

%typemap(argout) int *INT_OUT {
   jint ji;
   i = (jint) *$target;
   JCALL4(SetIntArrayRegion, jenv, $source, 0, 1, (jint *) &i);
}

%typemap(out) float * FLOAT_ARRAY_RETURN {
   if($source != NULL) {
     float *fp = $source;
     jfloat *jfp;
     int size = 0;
     int i;
 
     /* determine size of array */
     while(*fp++) size++;

     /* new float array */
     $target = JCALL1(NewFloatArray, jenv, size);

     /* copy elements to float array */
     jfp = JCALL2(GetFloatArrayElements, jenv, $target, 0);
     for(i=0; i<size; i++ )
       jfp[i] = (jfloat) $source[i];

     JCALL3(ReleaseFloatArrayElements, jenv, $target, jfp, 0);
   }
}

%typemap(jni) char *BYTE "jbyteArray"
%typemap(jtype) char *BYTE "byte[]"
%typemap(in) char *BYTE {
  $target = (char *) JCALL2(GetByteArrayElements, jenv, $source, 0);
}

%typemap(argout) char *BYTE {
  JCALL3(ReleaseByteArrayElements, jenv, $source, (jbyte *) $target, 0);
}

%typemap(ignore) JNIEnv * {
  $target = jenv;
}

%typemap(ignore) jclass jcls {
  $target = jcls;
}

%typemap(ignore) jobject jobj {
  $target = jobj;
}
