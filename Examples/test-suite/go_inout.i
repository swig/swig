// Test the goin and goout typemaps.

%module go_inout

%{
#include <string>
%}

%inline
%{

struct MyStruct {
  std::string str;
};

struct RetStruct {
  std::string str;
};

%}

// Write a typemap that calls C++ by converting in and out of JSON.

%go_import("encoding/json")

%insert(go_header)
%{

type In json.Marshaler

%}

%typemap(gotype) MyStruct "In"

%typemap(imtype) MyStruct "string"

%typemap(goin) MyStruct
%{
	{
		b, err := $input.MarshalJSON()
		if err != nil {
			panic(err)
		}
		$result = string(b)
	}
%}

%typemap(in) MyStruct
%{
  $1.str.assign($input.p, $input.n);
%}

%typemap(gotype) RetStruct "map[string]interface{}"

%typemap(imtype) RetStruct "string"

%typemap(out) RetStruct
%{
  $result = _swig_makegostring($1.str.data(), $1.str.length());
%}

%typemap(goout) RetStruct
%{
	if err := json.Unmarshal([]byte($1), &$result); err != nil {
		panic(err)
	}
%}

%inline
%{

RetStruct Same(MyStruct s)
{
  RetStruct r;
  r.str = s.str;
  return r;
}

%}
