//
// SWIG Typemap library
// for Java

%typemap(jtype) char *STRING "String"
%typemap(in) char *STRING {
  $1 = JCALL(GetStringUTFChars, jenv) $input, 0);
}

%typemap(argout) char *STRING {
  JCALL(ReleaseStringUTFChars, jenv) $1, $result);
}

%typemap(out) char *STRING {
  $result = (jarray) JCALL(NewStringUTF, jenv) $1);
}

%typemap(jtype) char **STRING_IN "String[]"
%typemap(jni) char **STRING_IN "jobjectArray"
%typemap(in) char **STRING_IN {
  int i;
  jsize l = JCALL(GetArrayLength, jenv) $input);
  $1 = (char **) malloc((l+1) * sizeof(char *));
  for(i=0; i<l; i++) {
    jstring js;
    char *cs;

    js = (jstring) JCALL(GetObjectArrayElement, jenv) $input, i);
    cs = (char *) JCALL(GetStringUTFChars, jenv) js, 0);
    $1[i] = cs;
  }
  $1[l] = '\0';
}

%typemap(argout) char **STRING_IN {
  /* should release strings obtained from GetStringUTFChars */
  free($result);
}

/* result must be a null terminated string */
%typemap(jtype) char **STRING_OUT "String[]"
%typemap(jni) char **STRING_OUT "jobjectArray"
%typemap(in) char **STRING_OUT (char *s) {
  $1 = &s;
}
%typemap(argout) char **STRING_OUT {
  if($result != NULL)
    JCALL(SetObjectArrayElement, jenv) $1, 0, JCALL(NewStringUTF, jenv) *$result));
}

/* a NULL terminated array of char* */
%typemap(jtype) char **STRING_RET "String[]"
%typemap(jni) char **STRING_RET "jarray"
%typemap(out) char **STRING_RET {
  if($1 != NULL) {
    char **p = $1;
    jsize size = 0;
    int i = 0;
    jclass strClass;
    
    while (*p++) size++; /* determine size */
    strClass = JCALL(FindClass, jenv) "java/lang/String");
    $result = JCALL(NewObjectArray, jenv) size, strClass, NULL);
    p = $1;
    while (*p) {
      jstring js = JCALL(NewStringUTF, jenv) *p);
      JCALL(SetObjectArrayElement, jenv) $result, i++, js);
      p++;
    }
  }
}

%typemap(jni) int *INT_OUT "jintArray"
%typemap(jtype) int *INT_OUT "int[]"
%typemap(in) int *INT_OUT (int i) {
   $1 = (int *)&i;
}

%typemap(argout) int *INT_OUT {
   jint ji;
   i = (jint) *$result;
   JCALL(SetIntArrayRegion, jenv) $1, 0, 1, (jint *) &i);
}

%typemap(out) float * FLOAT_ARRAY_RETURN {
   if($1 != NULL) {
     float *fp = $1;
     jfloat *jfp;
     int size = 0;
     int i;
 
     /* determine size of array */
     while(*fp++) size++;

     /* new float array */
     $result = JCALL(NewFloatArray, jenv) size);

     /* copy elements to float array */
     jfp = JCALL(GetFloatArrayElements, jenv) $result, 0);
     for(i=0; i<size; i++ )
       jfp[i] = (jfloat) $1[i];

     JCALL(ReleaseFloatArrayElements, jenv) $result, jfp, 0);
   }
}

%typemap(jni) char *BYTE "jbyteArray"
%typemap(jtype) char *BYTE "byte[]"
%typemap(in) char *BYTE {
  $1 = (char *) JCALL(GetByteArrayElements, jenv) $input, 0);
}

%typemap(argout) char *BYTE {
  JCALL(ReleaseByteArrayElements, jenv) $1, (jbyte *) $result, 0);
}

%typemap(ignore) JNIEnv * {
  $1 = jenv;
}

%typemap(ignore) jclass jcls {
  $1 = jcls;
}

%typemap(ignore) jobject jobj {
  $1 = jobj;
}
