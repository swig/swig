/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string and const std::string & <-> Swift String.
 * The C wrapper accepts/returns const char* and uses a thread-local for the
 * returned string to keep it alive until Swift copies it.
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {
  %naturalvar string;
  class string;
}

%typemap(ctype)  std::string                 "const char *"
%typemap(imtype) std::string                 "UnsafePointer<CChar>?"
%typemap(swifttype) std::string              "String"

%typemap(ctype)  const std::string &         "const char *"
%typemap(imtype) const std::string &         "UnsafePointer<CChar>?"
%typemap(swifttype) const std::string &      "String"

/* in typemaps: convert const char* -> std::string */
%typemap(in) std::string %{
    if ($input)
        $1 = std::string($input);
%}

%typemap(in) const std::string & (std::string temp) %{
    if ($input)
        temp = std::string($input);
    $1 = &temp;
%}

/* out typemap: convert std::string -> const char* (thread-local lifetime) */
%typemap(out) std::string %{
    static thread_local std::string _swig_swift_str_result;
    _swig_swift_str_result = $1;
    $result = _swig_swift_str_result.c_str();
%}

%typemap(out) const std::string & %{
    static thread_local std::string _swig_swift_strref_result;
    _swig_swift_strref_result = *$1;
    $result = _swig_swift_strref_result.c_str();
%}

/* Swift proxy: Swift String auto-bridges to const char* for input */
%typemap(swiftin)    std::string                "$swiftinput"
%typemap(swiftin)    const std::string &        "$swiftinput"

/* Swift proxy: convert returned const char* to Swift String */
%typemap(swiftout)   std::string  %{
    guard let rawStr = $imcall else {
        try swigCheckException()
        return ""
    }
    try swigCheckException()
    return String(cString: rawStr)
%}

%typemap(swiftout)   const std::string &  %{
    guard let rawStr = $imcall else {
        try swigCheckException()
        return ""
    }
    try swigCheckException()
    return String(cString: rawStr)
%}

/* Typecheck for overloaded functions */
%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING)
    std::string, const std::string &
    %{$1 = 1;%}

/* Director typemaps: C++ std::string -> const char* for callback */
%typemap(directorin) std::string        "$input.c_str()"
%typemap(directorin) const std::string &"$input.c_str()"

/* Director typemaps: const char* callback return -> std::string */
%typemap(directorout) std::string       "std::string($result ? $result : \"\")"

/* Director typemaps: UnsafePointer<CChar>? -> String in dispatch function */
%typemap(swiftdirectorin) std::string         "$input.map { String(cString: $0) } ?? \"\""
%typemap(swiftdirectorin) const std::string & "$input.map { String(cString: $0) } ?? \"\""

/* Director typemaps: String -> UnsafePointer<CChar>? in dispatch function */
%typemap(swiftdirectorout) std::string \
    "$input.withCString { ptr in swig_swift_director_store_string(ptr) }"
