/* -----------------------------------------------------------------------------
 * std_string_view.i
 *
 * Typemaps for std::string_view and const std::string_view&
 * These are mapped to a C# String and are passed around by value.
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
%typemap(ctype) string_view "const char *"
%typemap(imtype) string_view "string"
%typemap(cstype) string_view "string"

%typemap(csdirectorin) string_view "$iminput"
%typemap(csdirectorout) string_view "$cscall"

%typemap(in, canthrow=1) string_view
%{ if (!$input) {
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   $1 = std::string_view($input); %}
%typemap(out) string_view %{ $result = SWIG_csharp_string_callback(std::string($1).c_str()); %}

%typemap(directorout, canthrow=1, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) string_view
%{ if (!$input) {
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   /* possible thread/reentrant code problem */
   static std::string $1_str;
   $1_str = $input;
   $result = std::string_view($1_str); %}

%typemap(directorin) string_view %{ $input = std::string($1).c_str(); %}

%typemap(csin) string_view "$csinput"
%typemap(csout, excode=SWIGEXCODE) string_view {
    string ret = $imcall;$excode
    return ret;
  }

%typemap(typecheck) string_view = char *;

%typemap(throws, canthrow=1) string_view
%{ SWIG_CSharpSetPendingException(SWIG_CSharpApplicationException, std::string($1).c_str());
   return $null; %}

// const string_view &
%typemap(ctype) const string_view & "const char *"
%typemap(imtype) const string_view & "string"
%typemap(cstype) const string_view & "string"

%typemap(csdirectorin) const string_view & "$iminput"
%typemap(csdirectorout) const string_view & "$cscall"

%typemap(in, canthrow=1) const string_view &
%{ if (!$input) {
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   $*1_ltype $1_str($input);
   $1 = &$1_str; %}
%typemap(out) const string_view & %{ $result = SWIG_csharp_string_callback(std::string(*$1).c_str()); %}

%typemap(csin) const string_view & "$csinput"
%typemap(csout, excode=SWIGEXCODE) const string_view & {
    string ret = $imcall;$excode
    return ret;
  }

%typemap(directorout, canthrow=1, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const string_view &
%{ if (!$input) {
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   /* possible thread/reentrant code problem */
   static std::string $1_str;
   $1_str = $input;
   static $*1_ltype $1_strview;
   $1_strview = $1_str;
   $result = &$1_strview; %}

%typemap(directorin) const string_view & %{ $input = std::string($1).c_str(); %}

%typemap(csvarin, excode=SWIGEXCODE2) const string_view & %{
    set {
      $imcall;$excode
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) const string_view & %{
    get {
      string ret = $imcall;$excode
      return ret;
    } %}

%typemap(typecheck) const string_view & = char *;

%typemap(throws, canthrow=1) const string_view &
%{ SWIG_CSharpSetPendingException(SWIG_CSharpApplicationException, std::string($1).c_str());
   return $null; %}

}
