//
// SWIG typemaps for std::string
// Luigi Ballabio, Tal Shalif and William Fulton
// May 7, 2002
//
// Java implementation
//
/* ------------------------------------------------------------------------
  Typemaps for std::string and const std::string&
  These are mapped to a Java String and are passed around by value.

  To use non-const std::string references use the following %apply.  Note 
  that they are passed by value.
  %apply const std::string & {std::string &};
  ------------------------------------------------------------------------ */

%include exception.i

%{
#include <string>
%}

namespace std {

class string;

// string
%typemap(jni) string "jstring"
%typemap(jtype) string "String"
%typemap(jstype) string "String"
%typemap(javadirectorin) string "$jniinput"
%typemap(javadirectorout) string "$javacall"

%typemap(in) string 
%{if(!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::string");
    return $null;
  } 
  const char *$1_pstr = (const char *)jenv->GetStringUTFChars($input, 0); 
  if (!$1_pstr) return $null;
  $1 =  std::string($1_pstr);
  jenv->ReleaseStringUTFChars($input, $1_pstr); %}

%typemap(directorout) string 
%{if(!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::string");
    return $null;
  } 
  const char *$1_pstr = (const char *)jenv->GetStringUTFChars($input, 0); 
  if (!$1_pstr) return $null;
  $1 =  std::string($1_pstr);
  jenv->ReleaseStringUTFChars($input, $1_pstr); %}

%typemap(directorin,descriptor="Ljava/lang/String;") string 
%{ $input = jenv->NewStringUTF($1.c_str()); %}

%typemap(out) string 
%{ $result = jenv->NewStringUTF($1.c_str()); %}

%typemap(javain) string "$javainput"

%typemap(javaout) string {
    return $jnicall;
  }

%typemap(typecheck) string = char *;

%typemap(throws) string %{
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, $1.c_str());
  return $null;
%}

// const string &
%typemap(jni) const string & "jstring"
%typemap(jtype) const string & "String"
%typemap(jstype) const string & "String"
%typemap(javadirectorin) const string & "$jniinput"
%typemap(javadirectorout) const string & "$javacall"

%typemap(in) const string &
%{if(!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::string");
    return $null;
  }
  const char *$1_pstr = (const char *)jenv->GetStringUTFChars($input, 0); 
  if (!$1_pstr) return $null;
  std::string $1_str($1_pstr);
  $1 = &$1_str;
  jenv->ReleaseStringUTFChars($input, $1_pstr); %}

%typemap(directorout,warning=SWIG_WARN_TYPEMAP_THREAD_UNSAFE) const string &
%{if(!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::string");
    return $null;
  }
  const char *$1_pstr = (const char *)jenv->GetStringUTFChars($input, 0); 
  if (!$1_pstr) return $null;
  /* possible thread/reentrant code problem */
  static std::string $1_str($1_pstr);
  $1 = &$1_str;
  jenv->ReleaseStringUTFChars($input, $1_pstr); %}

%typemap(directorin,descriptor="Ljava/lang/String;") const string &
%{ $input = jenv->NewStringUTF($1.c_str()); %}

%typemap(out) const string & 
%{ $result = jenv->NewStringUTF($1->c_str()); %}

%typemap(javain) const string & "$javainput"

%typemap(javaout) const string & {
    return $jnicall;
  }

%typemap(typecheck) const string & = char *;

%typemap(throws) const string & %{
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, $1.c_str());
  return $null;
%}

}

/* ------------------------------------------------------------------------
  Typemaps for std::wstring and const std::wstring&

  These are mapped to a Java String and are passed around by value.
  Warning: Unicode / multibyte characters are handled differently on different 
  OSs so the std::wstring typemaps may not always work as intended. Therefore 
  a #define is required to use them.

  To use non-const std::wstring references use the following %apply.  Note 
  that they are passed by value.
  %apply const std::wstring & {std::wstring &};
  ------------------------------------------------------------------------ */

#ifdef SWIGJAVA_WSTRING

namespace std {

class wstring;

// wstring
%typemap(jni) wstring "jstring"
%typemap(jtype) wstring "String"
%typemap(jstype) wstring "String"
%typemap(javadirectorin) wstring "$jniinput"
%typemap(javadirectorout) wstring "$javacall"

%typemap(in) wstring
%{if(!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::wstring");
    return $null;
  }
  const jchar *$1_pstr = jenv->GetStringChars($input, 0);
  if (!$1_pstr) return $null;
  jsize $1_len = jenv->GetStringLength($input);
  if ($1_len) {
    wchar_t *conv_buf = new wchar_t[$1_len];
    for (jsize i = 0; i < $1_len; ++i) {
       conv_buf[i] = $1_pstr[i];
    }
    $1 =  std::wstring(conv_buf, $1_len);
    delete [] conv_buf;
  }
  jenv->ReleaseStringChars($input, $1_pstr);
 %}

%typemap(directorout) wstring
%{if(!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::wstring");
    return $null;
  }
  const jchar *$1_pstr = jenv->GetStringChars($input, 0);
  if (!$1_pstr) return $null;
  jsize $1_len = jenv->GetStringLength($input);
  if ($1_len) {
    wchar_t *conv_buf = new wchar_t[$1_len];
    for (jsize i = 0; i < $1_len; ++i) {
       conv_buf[i] = $1_pstr[i];
    }
    $1 =  std::wstring(conv_buf, $1_len);
    delete [] conv_buf;
  }
  jenv->ReleaseStringChars($input, $1_pstr);
 %}

%typemap(directorin,descriptor="Ljava/lang/String;") wstring 
%{jsize $1_len = $1.length();
  jchar *conv_buf = new jchar[$1_len];
  for (jsize i = 0; i < $1_len; ++i) {
    conv_buf[i] = (jchar)$1[i];
  }
  $input = jenv->NewString(conv_buf, $1_len);
  delete [] conv_buf; %}

%typemap(out) wstring
%{jsize $1_len = $1.length();
  jchar *conv_buf = new jchar[$1_len];
  for (jsize i = 0; i < $1_len; ++i) {
    conv_buf[i] = (jchar)$1[i];
  }
  $result = jenv->NewString(conv_buf, $1_len);
  delete [] conv_buf; %}

%typemap(javain) wstring "$javainput"

%typemap(javaout) wstring {
    return $jnicall;
  }

// const wstring &
%typemap(jni) const wstring & "jstring"
%typemap(jtype) const wstring & "String"
%typemap(jstype) const wstring & "String"
%typemap(javadirectorin) const wstring & "$jniinput"
%typemap(javadirectorout) const wstring & "$javacall"

%typemap(directorout,warning=SWIG_WARN_TYPEMAP_THREAD_UNSAFE) const wstring &
%{if(!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::wstring");
    return $null;
  }
  const jchar *$1_pstr = jenv->GetStringChars($input, 0);
  if (!$1_pstr) return $null;
  jsize $1_len = jenv->GetStringLength($input);
  static std::wstring $1_str;
  if ($1_len) {
    wchar_t *conv_buf = new wchar_t[$1_len];
    for (jsize i = 0; i < $1_len; ++i) {
       conv_buf[i] = $1_pstr[i];
    }
    $1_str = std::wstring(conv_buf, $1_len);
    delete [] conv_buf;
  }
  $1 = &$1_str;
  jenv->ReleaseStringChars($input, $1_pstr); %}

%typemap(directorout) const wstring & 
%{if(!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::wstring");
    return $null;
  }
  const jchar *$1_pstr = jenv->GetStringChars($input, 0);
  if (!$1_pstr) return $null;
  jsize $1_len = jenv->GetStringLength($input);
  std::wstring $1_str;
  if ($1_len) {
    wchar_t *conv_buf = new wchar_t[$1_len];
    for (jsize i = 0; i < $1_len; ++i) {
       conv_buf[i] = $1_pstr[i];
    }
    $1_str = std::wstring(conv_buf, $1_len);
    delete [] conv_buf;
  }
  $1 = &$1_str;
  jenv->ReleaseStringChars($input, $1_pstr); %}

%typemap(directorin,descriptor="Ljava/lang/String;") const wstring &
%{jsize $1_len = $1.length();
  jchar *conv_buf = new jchar[$1_len];
  for (jsize i = 0; i < $1_len; ++i) {
    conv_buf[i] = (jchar)($1)[i];
  }
  $input = jenv->NewString(conv_buf, $1_len);
  delete [] conv_buf; %}

%typemap(out) const wstring & 
%{jsize $1_len = $1->length();
  jchar *conv_buf = new jchar[$1_len];
  for (jsize i = 0; i < $1_len; ++i) {
    conv_buf[i] = (jchar)(*$1)[i];
  }
  $result = jenv->NewString(conv_buf, $1_len);
  delete [] conv_buf; %}

%typemap(javain) const wstring & "$javainput"

%typemap(javaout) const wstring & {
    return $jnicall;
  }

}

#endif

