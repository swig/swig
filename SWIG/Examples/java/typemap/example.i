/* File : example.i */
%module example
%{
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

/* default behaviour is that of input arg, Java cannot return a value in a 
 * string argument, so any changes made by f1(char*) will not be seen in the Java
 * string passed to the f1 function.
*/
void f1(char *s);

%include various.i

/* use the BYTE argout typemap to get around this. Changes in the string by 
 * f2 can be seen in Java. */
void f2(char *BYTE);

/* alternative approach uses a StringBuffer typemap for argout */

/* what is the corresponding jni type */
%typemap(jni) char *SBUF "jobject"

/* what types to use in java source code */
%typemap(jtype) char *SBUF "StringBuffer"
%typemap(jstype) char *SBUF "StringBuffer"

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

  if($1 != NULL) {
    /* append the result to the empty StringBuffer */
    sbufClass = (*jenv)->GetObjectClass(jenv, $input);
    appendStringID = (*jenv)->GetMethodID(jenv, sbufClass, "append", "(Ljava/lang/String;)Ljava/lang/StringBuffer;");
    (*jenv)->CallObjectMethod(jenv, $input, appendStringID, (*jenv)->NewStringUTF(jenv, $1));
    if($input != NULL) (*jenv)->ReleaseStringUTFChars(jenv, $input, $1);
  }  
}
/* Prevent the default freearg typemap from being used */
%typemap(freearg) char *SBUF ""

/* apply the new typemap to our function */
void f3(char *SBUF);
