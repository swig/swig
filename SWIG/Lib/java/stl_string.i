/*
 * Typemaps for standard C++ STL string
 * These are mapped to a Java String and are passed around by value.
 * Initial library contributed by Tal Shalif
 */

%{
#include <string>
%}

namespace std {

    // string
    %typemap(jni) string "jstring"
    %typemap(jtype) string "String"
    %typemap(jstype) string "String"

    %typemap(in) string 
    %{if($input) {
        const char *pstr = (const char *)jenv->GetStringUTFChars($input, 0); 
        if (!pstr) return $null;
        $1 =  std::string(pstr);
        jenv->ReleaseStringUTFChars($input, pstr);
      } 
      else {
        SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
        return $null;
      } %}

    %typemap(out) string 
    %{ $result = jenv->NewStringUTF($1.c_str()); %}

    // const string &
    %typemap(jni) const string & "jstring"
    %typemap(jtype) const string & "String"
    %typemap(jstype) const string & "String"

    %typemap(in) const string & 
    %{$1 = NULL;
      if($input) {
        const char *pstr = (const char *)jenv->GetStringUTFChars($input, 0); 
        if (!pstr) return $null;
        $1 =  new std::string(pstr);
        jenv->ReleaseStringUTFChars($input, pstr);
      } 
      else {
        SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
        return $null;
      } %}

    %typemap(freearg) const string & 
    %{ delete $1; %}

    %typemap(out) const string & 
    %{ $result = jenv->NewStringUTF($1->c_str()); %}

    /* To use non-const string references use the following %apply.  Note that they are passed by value.
    // string & 
    %apply const string & {string &};
    */

#ifdef SWIGJAVA_WSTRING
    // Warning: Unicode / multibyte characters are handled differently on different OSs so the wstring typemaps may not always work as intended. Therefore a preprocessor define is required to use them.
    // wstring
    %typemap(jni) wstring "jstring"
    %typemap(jtype) wstring "String"
    %typemap(jstype) wstring "String"

    %typemap(in) wstring
    %{if($input) {
        const jchar *pstr = jenv->GetStringChars($input, 0);
        if (!pstr) return $null;
        jsize len = jenv->GetStringLength($input);
        if (len) {
          wchar_t *conv_buf = new wchar_t[len];
          for (jsize i = 0; i < len; ++i) {
             conv_buf[i] = pstr[i];
           }
           $1 =  std::wstring(conv_buf, len);
           delete [] conv_buf;
        }
        jenv->ReleaseStringChars($input, pstr);
      } 
      else {
        SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null wstring");
        return $null;
      } %}

    %typemap(out) wstring
    %{jsize len = $1.length();
      jchar *conv_buf = new jchar[len];
      for (jsize i = 0; i < len; ++i) {
        conv_buf[i] = (jchar)$1[i];
      }
      $result = jenv->NewString(conv_buf, len);
      delete [] conv_buf; %}

    // const wstring &
    %typemap(jni) const wstring & "jstring"
    %typemap(jtype) const wstring & "String"
    %typemap(jstype) const wstring & "String"

    %typemap(in) const wstring & 
    %{$1 = NULL;
      if($input) {
        const jchar *pstr = jenv->GetStringChars($input, 0);
        if (!pstr) return $null;
        jsize len = jenv->GetStringLength($input);
        if (len) {
          wchar_t *conv_buf = new wchar_t[len];
          for (jsize i = 0; i < len; ++i) {
             conv_buf[i] = pstr[i];
           }
           $1 =  new std::wstring(conv_buf, len);
           delete [] conv_buf;
        }
        jenv->ReleaseStringChars($input, pstr);
      } 
      else {
        SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null wstring");
        return $null;
      } %}

    %typemap(out) const wstring & 
    %{jsize len = $1->length();
      jchar *conv_buf = new jchar[len];
      for (jsize i = 0; i < len; ++i) {
        conv_buf[i] = (jchar)(*$1)[i];
      }
      $result = jenv->NewString(conv_buf, len);
      delete [] conv_buf; %}

    /* To use non-const string references use the following %apply.  Note that they are passed by value.
    // string & 
    %apply const string & {string &};
    */
#endif

}
