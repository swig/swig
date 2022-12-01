// Test the goin and goout typemaps for directors.

%module(directors="1") go_director_inout

%include <std_string.i>

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

%go_import("encoding/json")

%insert(go_header)
%{

type GoRetStruct struct {
	Str string
}

%}

%typemap(gotype) RetStruct "GoRetStruct"

%typemap(imtype) RetStruct "string"

%typemap(goin) RetStruct
%{
	$result = $input.Str
%}

%typemap(in) RetStruct
%{
  $result.str.assign($input.p, $input.n);
%}

%typemap(out,fragment="AllocateString") RetStruct
%{
  $result = Swig_AllocateString($1.str.data(), $1.str.length());
%}

%typemap(goout,fragment="CopyString") RetStruct
%{
	$result = GoRetStruct{Str: swigCopyString($input)}
%}

%typemap(godirectorout) RetStruct
%{
	$result = $input.Str
%}

%typemap(directorout) RetStruct
%{
  $result.str.assign($input.p, $input.n);
%}

%typemap(godirectorin) RetStruct
%{
%}

%typemap(gotype) MyStruct "map[string]interface{}"

%typemap(imtype) MyStruct "string"

%typemap(goin) MyStruct
%{
	if b, err := json.Marshal($input); err != nil {
		panic(err)
	} else {
		$result = string(b)
	}
%}

%typemap(directorin,fragment="AllocateString") MyStruct
%{
  $input = Swig_AllocateString($1.str.data(), $1.str.length());
%}

%typemap(godirectorin,fragment="CopyString") MyStruct
%{
	if err := json.Unmarshal([]byte(swigCopyString($input)), &$result); err != nil {
		panic(err)
	}
%}

%typemap(out,fragment="AllocateString") MyStruct
%{
  $result = Swig_AllocateString($1.str.data(), $1.str.length());
%}

%typemap(goout,fragment="CopyString") MyStruct
%{
	$result = swigCopyString($input)
%}

%typemap(in) MyStruct
%{
  $1.str.assign($input.p, $input.n);
%}

%typemap(directorin) std::string & (_gostring_ temp) {
    $input = &temp;
    temp.p = (char *) $1.data();
    temp.n = $1.size();
}
%typemap(directorargout) std::string & {
    _gostring_ *tmp = $input;
    $1.assign(tmp->p, tmp->p + tmp->n);
}

%inline %{
// Helper functions for converting string arrays
#include <stdlib.h>
void *alloc_ptr_array(unsigned int len)
{
    return calloc(len, sizeof(void *));
}
void set_ptr_array(void *ain, unsigned int pos, void *val)
{
    void **a = (void **) ain;
    a[pos] = val;
}
void *get_ptr_array(void *ain, unsigned int pos)
{
    void **a = (void **) ain;
    return a[pos];
}
void free_ptr_array(void *ain)
{
    void **a = (void **) ain;
    unsigned int i;

    if (!a)
        return;
    for (i = 0; a[i]; i++) {
        free(a[i]);
    }
    free(a);
}
char *uintptr_to_string(void *in)
{
    return (char *) in;
}
void *string_to_uintptr(char *in)
{
    return strdup(in);
}
%}

// These typemaps convert between an array of strings in Go and a
// const char** that is NULL terminated in C++.
%typemap(gotype) (const char * const *) "[]string"
%typemap(imtype) (const char * const *) "uintptr"
%typemap(goin) (const char * const *) {
	if $input == nil || len($input) == 0 {
		$result = 0
	} else {
		$result = Alloc_ptr_array(uint(len($input) + 1))
		defer func() {
			Free_ptr_array($result)
		}()
		var i uint
		for i = 0; i < uint(len($input)); i++ {
			Set_ptr_array($result, i, String_to_uintptr($input[i]))
		}
	}
}
%typemap(in) (const char * const *) {
    $1 = (char **) $input;
}
%typemap(godirectorin) (const char * const *) {
	if ($input == 0) {
		$result = nil
	} else {
		var i uint
		for i = 0; ; i++ {
			var v uintptr = Get_ptr_array($input, i)
			if v == 0 {
				break
			}
		}
		if i == 0 {
			$result = nil
		} else {
			$result = make([]string, i)
			for i = 0; ; i++ {
				var v uintptr = Get_ptr_array($input, i)
				if v == 0 {
					break
				}
				$result[i] = Uintptr_to_string(v)
			}
		}
	}
}

%feature("director") MyClass;

%inline
%{

class MyClass {
 public:
  virtual ~MyClass() {}
  virtual RetStruct Adjust(MyStruct s) {
    RetStruct r;
    r.str = s.str;
    return r;
  }

  void CallS4(const char * const *strarray);
  virtual void S1(std::string s);
  virtual void S2(std::string& s) = 0;
  virtual void S3(std::string* s) = 0;
  virtual void S4(const char * const *strarray);
  virtual int S5(const std::string* s);
};

void MyClass::S1(std::string s) {
    throw "Base S1 called!";
}

void MyClass::S4(const char * const *strarray) {
    throw "Base S4 called!";
}

void MyClass::CallS4(const char * const *strarray) {
    this->S4(strarray);
}

int MyClass::S5(const std::string* s) {
    if (s) {
        return (*s)[0];
    } else {
        return 0;
    }
}

%}
