/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string, std::string& and const std::string&
 * These are mapped to a HHVM String and are passed around by value.
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {

%naturalvar string;

class string;

// string
%typemap(hni_parmtype) string, const string & "const HPHP::String&"
%typemap(hni_rttype) string, const string & "HPHP::String";
%typemap(php_type) string, const string & "string";
%typemap(variant_out) string ".toString()"

%typemap(in) string %{$1 = $input.toCppString();%}
%typemap(out) string %{$result = HPHP::String($1);%}

%typemap(in) const string & ($*1_ltype temp)
%{
	temp = $input.toCppString();
	$1 = &temp;
%}
%typemap(out) const string & %{$result = HPHP::String(*$1);%}
%typemap(argout) const string & ""

%typemap(typecheck) string, string&, const string & = char *;

// string &
%typemap(hni_parmtype) string & "HPHP::VRefParam"
%typemap(hni_rttype) string & "HPHP::Variant";
%typemap(php_type) string & "mixed&";

%typemap(in) string & ($*1_ltype temp)
%{
	temp = $input.toString().toCppString();
	$1 = &temp;
%}
%typemap(out) string & %{$result = HPHP::Variant(HPHP::String(*$1));%}
%typemap(argout) string & %{$result.assignIfRef(*$1);%}

%typemap(throws) string, const string& %{
	HPHP::SystemLib::throwRuntimeExceptionObject($1);
	return;
%}
}

