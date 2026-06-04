/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string and const std::string&
 * These are mapped to a Java String and are passed around by value.
 *
 * To use non-const std::string references use the following %apply.  Note 
 * that they are passed by value.
 * %apply const std::string & {std::string &};
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {

%naturalvar string;

class string;

// string
%typemap(jni) string "jstring"
%typemap(ktype) string "String"
%typemap(kstype) string "String"
%typemap(kdirectorin) string "$jniinput"
%typemap(kdirectorout) string "$kotlincall"

%typemap(in) string 
%{ if(!$input) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     return $null;
    } 
    const char *$1_pstr = jenv->GetStringUTFChars($input, 0); 
    if (!$1_pstr) return $null;
    $1.assign($1_pstr);
    jenv->ReleaseStringUTFChars($input, $1_pstr); %}

%typemap(directorout) string 
%{ if(!$input) {
     if (!jenv->ExceptionCheck()) {
       SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     }
     return $null;
   } 
   const char *$1_pstr = jenv->GetStringUTFChars($input, 0); 
   if (!$1_pstr) return $null;
   $result.assign($1_pstr);
   jenv->ReleaseStringUTFChars($input, $1_pstr); %}

%typemap(directorin,descriptor="Ljava/lang/String;") string 
%{ $input = jenv->NewStringUTF($1.c_str());
   Swig::LocalRefGuard $1_refguard(jenv, $input); %}

%typemap(out) string 
%{ $result = jenv->NewStringUTF($1.c_str()); %}

%typemap(kin) string "$kotlininput"

%typemap(kout) string {
    return $jnicall;
  }

%typemap(typecheck) string = char *;

%typemap(throws) string
%{ SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, $1.c_str());
   return $null; %}

// const string &
%typemap(jni) const string & "jstring"
%typemap(ktype) const string & "String"
%typemap(kstype) const string & "String"
%typemap(kdirectorin) const string & "$jniinput"
%typemap(kdirectorout) const string & "$kotlincall"

%typemap(in) const string &
%{ if(!$input) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     return $null;
   }
   const char *$1_pstr = jenv->GetStringUTFChars($input, 0); 
   if (!$1_pstr) return $null;
   $*1_ltype $1_str($1_pstr);
   $1 = &$1_str;
   jenv->ReleaseStringUTFChars($input, $1_pstr); %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const string &
%{ if(!$input) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     return $null;
   }
   const char *$1_pstr = jenv->GetStringUTFChars($input, 0); 
   if (!$1_pstr) return $null;
   /* possible thread/reentrant code problem */
   static $*1_ltype $1_str;
   $1_str = $1_pstr;
   $result = &$1_str;
   jenv->ReleaseStringUTFChars($input, $1_pstr); %}

%typemap(directorin,descriptor="Ljava/lang/String;") const string &
%{ $input = jenv->NewStringUTF($1.c_str());
   Swig::LocalRefGuard $1_refguard(jenv, $input); %}

%typemap(out) const string & 
%{ $result = jenv->NewStringUTF($1->c_str()); %}

%typemap(kin) const string & "$kotlininput"

%typemap(kout) const string & {
    return $jnicall;
  }

%typemap(typecheck) const string & = char *;

%typemap(throws) const string &
%{ SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, $1.c_str());
   return $null; %}

}

