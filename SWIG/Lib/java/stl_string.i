//-*-c++-*-
/*
 * typemaps for standard C++ string and wstring
 * by: Tal Shalif <tal@slt.atr.co.jp>
 */
/* what type to use in java source code */
%typemap(jtype) const string & "String"

/* what is the corresponding jni type */
%typemap(jni) const string & "jstring"

/* how to convert the c++ type to the java type */
%typemap(out) const string & {
 $target = JCALL(NewStringUTF, jenv) $source->c_str());
}

/* how to convert java type to requested c++ type */
%typemap(in) const string & {
  $target = NULL;
  if($source != NULL) {
    /* get the String from the StringBuffer */
    char *p = (char *)jenv->GetStringUTFChars($source, 0); 
    $target =  new string(p);
    JCALL(ReleaseStringUTFChars, jenv) $source, p);
  }
}
/* free resource once finished using */
%typemap(freearg) const string & {
  delete $target;
}

%typemap(jtype) string & = const string &;
%typemap(jni) string & = const string &;
%typemap(in) string & = const string &;
%typemap(out) string & = const string &;
%typemap(freearg) string & = const string &;

/* what type to use in java source code */
%typemap(jtype) const wstring & "String"

/* what is the corresponding jni type */
%typemap(jni) const wstring & "jstring"

/* how to convert the c++ type to the java type */
%typemap(out) const wstring & {
  unsigned int len = $source->length();
  jchar *conv_buf = new jchar[len];
  for (unsigned int i = 0; i < len; ++i) {
    conv_buf[i] = (jchar)(*$source)[i];
  }
 $target = JCALL(NewString, jenv) conv_buf, len);
 delete [] conv_buf;
}

/* how to convert java type to requested c++ type */
%typemap(in) const wstring & {
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


%typemap(jtype) wstring & = const wstring &;
%typemap(jni) wstring & = const wstring &;
%typemap(in) wstring & = const wstring &;
%typemap(out) wstring & = const wstring &;
%typemap(freearg) wstring & = const wstring &;

