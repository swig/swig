/* -----------------------------------------------------------------------------
 * std_string_view.i
 *
 * Typemaps for std::string_view and const std::string_view&
 * These are mapped to a Java String and are passed around by value.
 *
 * To use non-const std::string_view references use the following %apply.  Note
 * that they are passed by value.
 * %apply const std::string_view & {std::string_view &};
 * ----------------------------------------------------------------------------- */

%{
#include <string_view>
#include <string>
%}

namespace std {

%naturalvar string_view;

class string_view;

// string_view
%typemap(jni) string_view "jstring"
%typemap(jtype) string_view "String"
%typemap(jstype) string_view "String"
%typemap(javadirectorin) string_view "$jniinput"
%typemap(javadirectorout) string_view "$javacall"

%typemap(in) string_view
%{ if(!$input) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     return $null;
   }
   const char *$1_pstr = (const char *)jenv->GetStringUTFChars($input, 0);
   if (!$1_pstr) return $null;
   $1 = std::string_view($1_pstr); %}

/* std::string_view requires the string data to remain valid while the
 * string_view is in use. */
%typemap(freearg) string_view
%{ jenv->ReleaseStringUTFChars($input, $1_pstr); %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) string_view
%{ if(!$input) {
     if (!jenv->ExceptionCheck()) {
       SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     }
     return $null;
   }
   const char *$1_pstr = (const char *)jenv->GetStringUTFChars($input, 0);
   if (!$1_pstr) return $null;
   /* possible thread/reentrant code problem */
   static std::string $1_str;
   $1_str = $1_pstr;
   $result = std::string_view($1_str);
   jenv->ReleaseStringUTFChars($input, $1_pstr); %}

/* std::string_view::data() isn't zero-byte terminated, but NewStringUTF()
 * requires a zero byte so it seems we have to make a copy (ick).  The
 * cleanest way to do that seems to be via a temporary std::string.
 */
%typemap(directorin,descriptor="Ljava/lang/String;") string_view
%{ $input = jenv->NewStringUTF(std::string($1).c_str());
   Swig::LocalRefGuard $1_refguard(jenv, $input); %}

%typemap(out) string_view
%{ $result = jenv->NewStringUTF(std::string($1).c_str()); %}

%typemap(javain) string_view "$javainput"

%typemap(javaout) string_view {
    return $jnicall;
  }

%typemap(typecheck) string_view = char *;

%typemap(throws) string_view
%{ SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, std::string($1).c_str());
   return $null; %}

// const string_view &
%typemap(jni) const string_view & "jstring"
%typemap(jtype) const string_view & "String"
%typemap(jstype) const string_view & "String"
%typemap(javadirectorin) const string_view & "$jniinput"
%typemap(javadirectorout) const string_view & "$javacall"

%typemap(in) const string_view &
%{ if(!$input) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     return $null;
   }
   const char *$1_pstr = (const char *)jenv->GetStringUTFChars($input, 0);
   if (!$1_pstr) return $null;
   $*1_ltype $1_str($1_pstr);
   $1 = &$1_str; %}

/* std::string_view requires the string data to remain valid while the
 * string_view is in use. */
%typemap(freearg) const string_view &
%{ jenv->ReleaseStringUTFChars($input, $1_pstr); %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const string_view &
%{ if(!$input) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     return $null;
   }
   const char *$1_pstr = (const char *)jenv->GetStringUTFChars($input, 0);
   if (!$1_pstr) return $null;
   /* possible thread/reentrant code problem */
   static std::string $1_str;
   $1_str = $1_pstr;
   static $*1_ltype $1_strview;
   $1_strview = $1_str;
   $result = &$1_strview;
   jenv->ReleaseStringUTFChars($input, $1_pstr); %}

%typemap(directorin,descriptor="Ljava/lang/String;") const string_view &
%{ $input = jenv->NewStringUTF(std::string($1).c_str());
   Swig::LocalRefGuard $1_refguard(jenv, $input); %}

%typemap(out) const string_view &
%{ $result = jenv->NewStringUTF(std::string(*$1).c_str()); %}

%typemap(javain) const string_view & "$javainput"

%typemap(javaout) const string_view & {
    return $jnicall;
  }

%typemap(typecheck) const string_view & = char *;

%typemap(throws) const string_view &
%{ SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, std::string($1).c_str());
   return $null; %}

}
