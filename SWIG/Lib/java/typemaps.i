//-*-c++-*-
// SWIG Typemap library
// for Java

%typemap(java,jtype) char *STRING {String}
%typemap(java,in) char *STRING {
  $target = JCALL(GetStringUTFChars, jenv) $source, 0);
}

%typemap(java,argout) char *STRING {
  JCALL(ReleaseStringUTFChars, jenv) $source, $target);
}

%typemap(java,out) char *STRING {
  $target = (jarray) JCALL(NewStringUTF, jenv) $source);
}

%typemap(java,jtype) char **STRING_IN {String[]}
%typemap(java,jni) char **STRING_IN {jobjectArray}
%typemap(java,in) char **STRING_IN {
  int i;
  jsize l = JCALL(GetArrayLength, jenv) $source);
  $target = (char **) malloc((l+1) * sizeof(char *));
  for(i=0; i<l; i++) {
    jstring js;
    char *cs;

    js = (jstring) JCALL(GetObjectArrayElement, jenv) $source, i);
    cs = (char *) JCALL(GetStringUTFChars, jenv) js, 0);
    $target[i] = cs;
  }
  $target[l] = '\0';
}

%typemap(java,argout) char **STRING_IN {
  /* should release strings obtained from GetStringUTFChars */
  free($target);
}

/* result must be a null terminated string */
%typemap(java,jtype) char **STRING_OUT {String[]}
%typemap(java,jni) char **STRING_OUT {jobjectArray}
%typemap(java,in) char **STRING_OUT (char *s) {
  $target = &s;
}
%typemap(java,argout) char **STRING_OUT {
  if($target != NULL)
    JCALL(SetObjectArrayElement, jenv) $source, 0, JCALL(NewStringUTF, jenv) *$target));
}

/* a NULL terminated array of char* */
%typemap(java,jtype) char **STRING_RET {String[]}
%typemap(java,jni) char **STRING_RET {jarray}
%typemap(java,out) char **STRING_RET {
  if($source != NULL) {
    char **p = $source;
    jsize size = 0;
    int i = 0;
    jclass strClass;
    
    while (*p++) size++; /* determine size */
    strClass = JCALL(FindClass, jenv) "java/lang/String");
    $target = JCALL(NewObjectArray, jenv) size, strClass, NULL);
    p = $source;
    while (*p) {
      jstring js = JCALL(NewStringUTF, jenv) *p);
      JCALL(SetObjectArrayElement, jenv) $target, i++, js);
      p++;
    }
  }
}

%typemap(java,jni) int *INT_OUT {jintArray}
%typemap(java,jtype) int *INT_OUT {int[]}
%typemap(java,in) int *INT_OUT (int i) {
   $target = (int *)&i;
}

%typemap(java,argout) int *INT_OUT {
   jint ji;
   i = (jint) *$target;
   JCALL(SetIntArrayRegion, jenv) $source, 0, 1, (jint *) &i);
}

%typemap(java,out) float * FLOAT_ARRAY_RETURN {
   if($source != NULL) {
     float *fp = $source;
     jfloat *jfp;
     int size = 0;
     int i;
 
     /* determine size of array */
     while(*fp++) size++;

     /* new float array */
     $target = JCALL(NewFloatArray, jenv) size);

     /* copy elements to float array */
     jfp = JCALL(GetFloatArrayElements, jenv) $target, 0);
     for(i=0; i<size; i++ )
       jfp[i] = (jfloat) $source[i];

     JCALL(ReleaseFloatArrayElements, jenv) $target, jfp, 0);
   }
}

%typemap(java,jni) char *BYTE {jbyteArray}
%typemap(java,jtype) char *BYTE {byte[]}
%typemap(java,in) char *BYTE {
  $target = (char *) JCALL(GetByteArrayElements, jenv) $source, 0);
}

%typemap(java,argout) char *BYTE {
  JCALL(ReleaseByteArrayElements, jenv) $source, (jbyte *) $target, 0);
}

%typemap(java,ignore) JNIEnv * {
  $target = jenv;
}

%typemap(java,ignore) jclass jcls {
  $target = jcls;
}

%typemap(java,ignore) jobject jobj {
  $target = jobj;
}

/*
 * typemaps for standard C++ string and wstring
 * by: Tal Shalif <tal@slt.atr.co.jp>
 */
/* what type to use in java source code */
%typemap(java,jtype) const string & {String}

/* what is the corresponding jni type */
%typemap(java,jni) const string & {jstring}

/* how to convert the c++ type to the java type */
%typemap(java,out) const string & {
 $target = JCALL(NewStringUTF, jenv) $source->c_str());
}

/* how to convert java type to requested c++ type */
%typemap(java,in) const string & {
  $target = NULL;
  if($source != NULL) {
    /* get the String from the StringBuffer */
    char *p = (char *)jenv->GetStringUTFChars($source, 0); 
    $target =  new string(p);
    JCALL(ReleaseStringUTFChars, jenv) $source, p);
  }
}
/* free resource once finished using */
%typemap(java,freearg) const string & {
  delete $target;
}

%typemap(java,jtype) string & = const string &;
%typemap(java,jni) string & = const string &;
%typemap(java,in) string & = const string &;
%typemap(java,out) string & = const string &;
%typemap(java,freearg) string & = const string &;

/* what type to use in java source code */
%typemap(java,jtype) const wstring & {String}

/* what is the corresponding jni type */
%typemap(java,jni) const wstring & {jstring}

/* how to convert the c++ type to the java type */
%typemap(java,out) const wstring & {
  unsigned int len = $source->length();
  jchar *conv_buf = new jchar[len];
  for (unsigned int i = 0; i < len; ++i) {
    conv_buf[i] = (jchar)(*$source)[i];
  }
 $target = JCALL(NewString, jenv) conv_buf, len);
 delete [] conv_buf;
}

/* how to convert java type to requested c++ type */
%typemap(java,in) const wstring & {
  $target = NULL;
  if($source != NULL) {
    /* get the String from the StringBuffer */
    const jchar *jchar_p = jenv->GetStringChars($source, 0);
    unsigned int len;
    for (len = 0; jchar_p[len]; ++len);
    if (len) {
      wchar_t *conv_buf = new wchar_t[len];
      for (unsigned int i = 0; i < len; ++i) {
         conv_buf[i] = jchar_p[i];
       }
       $target =  new wstring(conv_buf, len);
       delete [] conv_buf;
    }

    JCALL(ReleaseStringChars, jenv) $source, jchar_p);
  }
}


%typemap(java,jtype) wstring & = const wstring &;
%typemap(java,jni) wstring & = const wstring &;
%typemap(java,in) wstring & = const wstring &;
%typemap(java,out) wstring & = const wstring &;
%typemap(java,freearg) wstring & = const wstring &;

