/*
 * Typemaps for standard C++ STL string
 * These are mapped to a Java String and are passed around by value.
 * Initial library contributed by Tal Shalif
 */

%{
#include <string>
%}

// std::string
%typemap(jni) std::string "jstring"
%typemap(jtype) std::string "String"
%typemap(jstype) std::string "String"

%typemap(in) std::string 
%{if($input) {
    const char *pstr = (const char *)jenv->GetStringUTFChars($input, 0); 
    if (!pstr) return $null;
    $1 =  std::string(pstr);
    jenv->ReleaseStringUTFChars($input, pstr);
  } 
  else {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::string");
    return $null;
  } %}

%typemap(out) std::string 
%{ $result = jenv->NewStringUTF($1.c_str()); %}

// const std::string &
%typemap(jni) const std::string & "jstring"
%typemap(jtype) const std::string & "String"
%typemap(jstype) const std::string & "String"

%typemap(in) const std::string & 
%{$1 = NULL;
  if($input) {
    const char *pstr = (const char *)jenv->GetStringUTFChars($input, 0); 
    if (!pstr) return $null;
    $1 =  new std::string(pstr);
    jenv->ReleaseStringUTFChars($input, pstr);
  } 
  else {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::string");
    return $null;
  } %}

%typemap(freearg) const std::string & 
%{ delete $1; %}

%typemap(out) const std::string & 
%{ $result = jenv->NewStringUTF($1->c_str()); %}

// For using std::string in the global namespace
%apply const std::string & {const string &};
%apply std::string {string};

/* To use non-const std::string references use the following %apply.  Note that they are passed by value.
// std::string & 
%apply const std::string & {std::string &};
%apply std::string & {string &};
*/

#ifdef SWIGJAVA_WSTRING
// Warning: Unicode / multibyte characters are handled differently on different OSs so the std::wstring 
// typemaps may not always work as intended. Therefore a #define is required to use them.
// std::wstring
%typemap(jni) std::wstring "jstring"
%typemap(jtype) std::wstring "String"
%typemap(jstype) std::wstring "String"

%typemap(in) std::wstring
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
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::wstring");
    return $null;
  } %}

%typemap(out) std::wstring
%{jsize len = $1.length();
  jchar *conv_buf = new jchar[len];
  for (jsize i = 0; i < len; ++i) {
    conv_buf[i] = (jchar)$1[i];
  }
  $result = jenv->NewString(conv_buf, len);
  delete [] conv_buf; %}

// const std::wstring &
%typemap(jni) const std::wstring & "jstring"
%typemap(jtype) const std::wstring & "String"
%typemap(jstype) const std::wstring & "String"

%typemap(in) const std::wstring & 
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
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::wstring");
    return $null;
  } %}

%typemap(out) const std::wstring & 
%{jsize len = $1->length();
  jchar *conv_buf = new jchar[len];
  for (jsize i = 0; i < len; ++i) {
    conv_buf[i] = (jchar)(*$1)[i];
  }
  $result = jenv->NewString(conv_buf, len);
  delete [] conv_buf; %}

// For using std::wstring in the global namespace
%apply const std::wstring & {const wstring &};
%apply std::wstring {wstring};

/* To use non-const std::wstring references use the following %apply.  Note that they are passed by value.
// std::wstring & 
%apply const std::wstring & {std::wstring &};
%apply std::wstring & {wstring &};
*/

#endif

