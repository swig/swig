/*
 * Typemaps for standard C++ STL string and wstring
 * Contributed by: Tal Shalif <tal@slt.atr.co.jp>
 */
/* what type to use in java source code */
%typemap(jni) const string & "jstring"
%typemap(jtype) const string & "String"
%typemap(jstype) const string & "String"

/* how to convert java type to requested c++ type */
%typemap(in) const string & {
  $1 = NULL;
  if($input) {
    /* get the String from the StringBuffer */
    char *p = (char *)jenv->GetStringUTFChars($input, 0); 
    $1 =  new string(p);
    jenv->ReleaseStringUTFChars($input, p);
  }
}
/* free resource once finished using */
%typemap(freearg) const string & {
  delete $1;
}
/* how to convert the c++ type to the java type */
%typemap(out) const string & {
 $result = jenv->NewStringUTF($1->c_str());
}


%typemap(jni) string & = const string &;
%typemap(jtype) string & = const string &;
%typemap(jstype) string & = const string &;
%typemap(in) string & = const string &;
%typemap(freearg) string & = const string &;
%typemap(out) string & = const string &;

%typemap(jni) const wstring & "jstring"
%typemap(jtype) const wstring & "String"
%typemap(jstype) const wstring & "String"

/* how to convert java type to requested c++ type */
%typemap(in) const wstring & {
  $1 = NULL;
  if($input) {
    /* get the String from the StringBuffer */
    const jchar *jchar_p = jenv->GetStringChars($input, 0);
    unsigned int len;
    for (len = 0; jchar_p[len]; ++len);
    if (len) {
      wchar_t *conv_buf = new wchar_t[len];
      for (unsigned int i = 0; i < len; ++i) {
         conv_buf[i] = jchar_p[i];
       }
       $1 =  new wstring(conv_buf, len);
       delete [] conv_buf;
    }
    jenv->ReleaseStringChars($input, jchar_p);
  }
}
/* how to convert the c++ type to the java type */
%typemap(out) const wstring & {
  unsigned int len = $1->length();
  jchar *conv_buf = new jchar[len];
  for (unsigned int i = 0; i < len; ++i) {
    conv_buf[i] = (jchar)(*$1)[i];
  }
  $result = jenv->NewString(conv_buf, len);
  delete [] conv_buf;
}


%typemap(jni) wstring & = const wstring &;
%typemap(jtype) wstring & = const wstring &;
%typemap(jstype) wstring & = const wstring &;
%typemap(in) wstring & = const wstring &;
%typemap(out) wstring & = const wstring &;

