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
  f1(s);
}

void f3(char *s) {
  f1(s);
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
%typemap(jtype) char *SBUF "StringBuffer"

/* what is the corresponding jni type */
%typemap(jni) char *SBUF "jobject"

/* how to convert java type to requested c type */
%typemap(in) char *SBUF {
  jclass sbufClass;
  jmethodID toStringID;
  jmethodID setLengthID;
  jstring js;

  $1 = NULL;
  if($input != NULL) {
    /* get the String from the StringBuffer */
    sbufClass = (*jenv)->GetObjectClass(jenv, $input);
    toStringID = (*jenv)->GetMethodID(jenv, sbufClass, "toString", "()Ljava/lang/String;");
    js = (jstring) (*jenv)->CallObjectMethod(jenv, $input, toStringID);
    /* convert the String to a char * */
    $1 =  (char *)(*jenv)->GetStringUTFChars(jenv, js, 0); 
    /* zero the original StringBuffer, so we can replace it with the result */
    setLengthID = (*jenv)->GetMethodID(jenv, sbufClass, "setLength", "(I)V");
    (*jenv)->CallVoidMethod(jenv, $input, setLengthID, (jint) 0);
  }
}

/* how to convert the c type to the java type */
%typemap(argout) char *SBUF {
  jclass sbufClass;
  jmethodID appendStringID;

  if($result != NULL) {
    /* append the result to the empty StringBuffer */
    sbufClass = (*jenv)->GetObjectClass(jenv, $1);
    appendStringID = (*jenv)->GetMethodID(jenv, sbufClass, "append", "(Ljava/lang/String;)Ljava/lang/StringBuffer;");
    (*jenv)->CallObjectMethod(jenv, $1, appendStringID, (*jenv)->NewStringUTF(jenv, $result));
    if($1 != NULL) (*jenv)->ReleaseStringUTFChars(jenv, $1, $result);
  }  
}

/* apply the new typemap to our function */
void f3(char *SBUF);
