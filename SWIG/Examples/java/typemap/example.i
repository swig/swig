/* File : example.i */
%module example
%{
/* Put headers and other declarations here */

/*
   example of a function that returns a value in the char * argument
   normally used like:

   char buf[bigenough];
   f1(buf);
*/

void f1(char *s) {
  if(s != NULL) {
    sprintf(s, "hello world");
  }
}

void f2(char *s) {
  return f1(s);
}

void f3(char *s) {
  return f1(s);
}

%}

/* default behaviour is that of input arg, besides java cannot return
   a value in a string argument
*/
void f1(char *s);

%include typemaps.i

/* use the BYTE typemap to get around this, but the resulting code is ugly */
void f2(char *BYTE);

/* make a StringBuffer typemap to handle this case */

/* what type to use in java source code */
%typemap(java,jtype) char *SBUF {StringBuffer}

/* what is the corresponding jni type */
%typemap(java,jni) char *SBUF {jobject}

/* how to convert java type to requested c type */
%typemap(java,in) char *SBUF {
  jclass sbufClass;
  jmethodID toStringID;
  jmethodID setLengthID;
  jstring js;

  $target = NULL;
  if($source != NULL) {
    /* get the String from the StringBuffer */
    sbufClass = (*jenv)->GetObjectClass(jenv, $source);
    toStringID = (*jenv)->GetMethodID(jenv, sbufClass, "toString", "()Ljava/lang/String;");
    js = (jstring) (*jenv)->CallObjectMethod(jenv, $source, toStringID);
    /* convert the String to a char * */
    $target =  (char *)(*jenv)->GetStringUTFChars(jenv, js, 0); 
    /* zero the original StringBuffer, so we can replace it with the result */
    setLengthID = (*jenv)->GetMethodID(jenv, sbufClass, "setLength", "(I)V");
    (*jenv)->CallVoidMethod(jenv, $source, setLengthID, (jint) 0);
  }
}

/* how to convert the c type to the java type */
%typemap(java,argout) char *SBUF {
  jclass sbufClass;
  jmethodID appendStringID;

  if($target != NULL) {
    /* append the result to the empty StringBuffer */
    sbufClass = (*jenv)->GetObjectClass(jenv, $source);
    appendStringID = (*jenv)->GetMethodID(jenv, sbufClass, "append", "(Ljava/lang/String;)Ljava/lang/StringBuffer;");
    (*jenv)->CallObjectMethod(jenv, $source, appendStringID, (*jenv)->NewStringUTF(jenv, $target));
    if($source != NULL) (*jenv)->ReleaseStringUTFChars(jenv, $source, $target);
  }  
}

/* apply the new typemap to our function */
void f3(char *SBUF);
