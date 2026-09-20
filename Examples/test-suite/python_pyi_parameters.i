%module(directors="1") python_pyi_parameters
%feature("python:annotations", "typing");
%feature("python:stub:parameters");
%feature("compactdefaultargs");
%feature("compactdefaultargs", "0") plain;
%feature("compactdefaultargs", "0") combined_default;
%feature("python:stub:parameters", "0") broad;
%feature("kwargs") keywords;
%feature("kwargs") typemap_default_keyword;
%typemap(default) int typemap_value "$1 = 13;"
%feature("kwargs") Widget::keyword;
%include <std_string.i>
%include <typemaps.i>
%apply int *OUTPUT { int *out };
%ignore default_number;
%typemap(in) (int argc, char **argv) {
  $1 = (int)PyList_Size($input);
  if ($1 < 0) SWIG_fail;
  $2 = 0;
}
%typemap(pytyping) (int argc, char **argv) "typing.List[str]"
%inline %{
int default_number() { return 7; }
int size1() { return 3; }
int typemap_default(int typemap_value) { return typemap_value; }
int typemap_default_keyword(int typemap_value) { return typemap_value; }
int compact(int value, int extra = default_number()) { return value + extra; }
std::string plain(std::string value = std::string("ready")) { return value; }
int keywords(int value, int extra = default_number()) { return value + extra; }
int broad() { return 3; }
int actual(int n) { return n; }
std::string actual(std::string s) { return s; }
int grouped(int argc, char **argv) { (void)argv; return argc; }
void output(int *out) { *out = 11; }
int combined(int value, int *out) { *out = value + 1; return value; }
int combined_default(int *out, int value = default_number()) { *out = value + 1; return value; }
class Widget {
public:
  Widget(int value = default_number()) : value(value) {}
  int size1() const { return value; }
  int keyword(int value = default_number()) const { return value; }
  static int make(int value = default_number()) { return value; }
  int value;
};
%}

%feature("director") DirectorEmpty;
%feature("director") DirectorDefault;
%feature("director") DirectorParam;
%feature("director") DirectorCopy;
%feature("director") DirectorKeyword;
%feature("kwargs") DirectorKeyword::DirectorKeyword;
%typemap(pytyping) const DirectorCopy &, DirectorCopy * "DirectorCopy"
%ignore DirectorCopy::DirectorCopy();
%newobject make_director_copy;
%inline %{
struct DirectorEmpty {
  DirectorEmpty() {}
  virtual ~DirectorEmpty() {}
  virtual int get() const { return 1; }
};
struct DirectorDefault {
  DirectorDefault(int input_value = default_number()) : value(input_value) {}
  virtual ~DirectorDefault() {}
  virtual int get() const { return value; }
  int value;
};
struct DirectorParam {
  DirectorParam(int input_value) : value(input_value) {}
  virtual ~DirectorParam() {}
  virtual int get() const { return value; }
  int value;
};
struct DirectorKeyword {
  DirectorKeyword(int = 7) {}
  virtual ~DirectorKeyword() {}
  virtual int get() const { return 1; }
};
struct DirectorCopy {
  DirectorCopy() {}
  DirectorCopy(const DirectorCopy &) {}
  virtual ~DirectorCopy() {}
  virtual int get() const { return 2; }
};
DirectorCopy *make_director_copy() { return new DirectorCopy(); }
%}

// Named annotations must use the member name, not the generated %extend helper.
%typemap(pytyping) const char *named_annotations::Extended::qualified "str"
%typemap(pytyping) const char *bare "str"
%typemap(pytyping, out="str") const char *named_annotations::Extended::instance "typing.Optional[str]"
%typemap(pytyping) const char *text "str"
%inline %{
namespace named_annotations {
  struct Extended {};
}
%}
%extend named_annotations::Extended {
  static const char *qualified() { return "qualified"; }
  static const char *bare() { return "bare"; }
  const char *instance(const char *text) { return text; }
}
