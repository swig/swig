/*
 * SWIG Typemap library for Java
 * Various useful typemaps.
 *
*/

/* char **STRING_IN */
%typemap(jni) char **STRING_IN "jobjectArray"
%typemap(jtype) char **STRING_IN "String[]"
%typemap(jstype) char **STRING_IN "String[]"
%typemap(in) char **STRING_IN {
  int i;
  jsize sz = JCALL1(GetArrayLength, jenv, $input);
  $1 = (char **) calloc((sz+1),  sizeof(char *));
  for(i=0; i<sz; i++) {
    jstring js;
    char *cs;

    js = (jstring) JCALL2(GetObjectArrayElement, jenv, $input, i);
    cs = (char *) JCALL2(GetStringUTFChars, jenv, js, 0);
    $1[i] = cs;
  }
  $1[sz] = '\0';
}
%typemap(argout) char **STRING_IN %{
  /* should copy changes in char ** back into array and release strings obtained from GetStringUTFChars */
%}
%typemap(freearg) char **STRING_IN 
%{ free($1); %}

/* char **STRING_OUT - result must be a null terminated string */
%typemap(jni) char **STRING_OUT "jobjectArray"
%typemap(jtype) char **STRING_OUT "String[]"
%typemap(jstype) char **STRING_OUT "String[]"
%typemap(in) char **STRING_OUT (char *s) 
%{ $1 = &s; %}
%typemap(argout) char **STRING_OUT {
  if($1) {
     JCALL3(SetObjectArrayElement, jenv, $input, 0, JCALL1(NewStringUTF, jenv, *$1)); 
  }
}

/* char **STRING_RET - a NULL terminated array of char* */
%typemap(jni) char **STRING_RET "jarray"
%typemap(jtype) char **STRING_RET "String[]"
%typemap(jstype) char **STRING_RET "String[]"
%typemap(out) char **STRING_RET {
  if($1 != NULL) {
    char **p = $1;
    jsize size = 0;
    int i = 0;
    jclass strClass;
    
    while (*p++) size++; /* determine size */
    strClass = JCALL1(FindClass, jenv, "java/lang/String");
    $result = JCALL3(NewObjectArray, jenv, size, strClass, NULL);
    p = $1;
    while (*p) {
      jstring js = JCALL1(NewStringUTF, jenv, *p);
      JCALL3(SetObjectArrayElement, jenv, $result, i++, js);
      p++;
    }
  } 
}

/* float *FLOAT_ARRAY_RETURN */
%typemap(jni) float *FLOAT_ARRAY_RETURN "jfloatArray"
%typemap(jtype) float *FLOAT_ARRAY_RETURN "float[]"
%typemap(jstype) float *FLOAT_ARRAY_RETURN "float[]"
%typemap(out) float *FLOAT_ARRAY_RETURN {
  if($1) {
     float *fp = $1;
     jfloat *jfp;
     int size = 0;
     int i;
 
     /* determine size of array */
     while(*fp++) size++;

     /* new float array */
     $result = JCALL1(NewFloatArray, jenv, size);

     /* copy elements to float array */
     jfp = JCALL2(GetFloatArrayElements, jenv, $result, 0);
     for(i=0; i<size; i++ )
       jfp[i] = (jfloat) $1[i];

     JCALL3(ReleaseFloatArrayElements, jenv, $result, jfp, 0);
   } 
}

/* char *BYTE */
%typemap(jni) char *BYTE "jbyteArray"
%typemap(jtype) char *BYTE "byte[]"
%typemap(jstype) char *BYTE "byte[]"
%typemap(in) char *BYTE {
    $1 = (char *) JCALL2(GetByteArrayElements, jenv, $input, 0); 
}

%typemap(argout) char *BYTE {
    JCALL3(ReleaseByteArrayElements, jenv, $input, (jbyte *) $1, 0); 
}

/* Prevent default freearg typemap from being used */
%typemap(freearg) char *BYTE ""

