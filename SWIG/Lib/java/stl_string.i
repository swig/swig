//-*-c++-*-
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

