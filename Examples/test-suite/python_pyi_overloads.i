%module(directors="1") python_pyi_overloads
%feature("python:annotations", "typing");
%feature("python:stub:overloads");
%feature("compactdefaultargs");
%feature("python:stub:overloads", "0") broad;
%feature("python:stub:overloads", rank="-2") conflicting(long);
%feature("compactdefaultargs", "0") defaults;
%feature("compactdefaultargs", "0") ranked_defaults;
%feature("compactdefaultargs", "0") ranked_arities;
%include <std_string.i>
%include <typemaps.i>
%apply int *OUTPUT { int *out };
%apply double *OUTPUT { double *out };
%ignore default_number;
%typemap(in) (int argc, char **argv) {
  $1 = (int)PyList_Size($input);
  if ($1 < 0) SWIG_fail;
  $2 = 0;
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING) (int argc, char **argv) {
  $1 = PyList_Check($input);
}
%typemap(pytyping) (int argc, char **argv) "typing.List[str]"

%inline %{
int default_number() { return 7; }
int multi(int argc, char **argv) { (void)argv; return argc; }
double multi(double n) { return n; }
int ranked(int n) { return n; }
int ranked(bool n) { return n ? 17 : 0; }
int choose(int n) { return n; }
std::string choose(std::string s) { return s; }
int broad(int n) { return n; }
std::string broad(std::string s) { return s; }
int ranked_defaults(int n, int extra = 0) { return n + extra; }
std::string ranked_defaults(double) { return "floating"; }
int ranked_arities(int n, int extra = 0) { return n + extra; }
std::string ranked_arities(int, bool) { return "boolean"; }
int defaults(int n, int extra = 3) { return n + extra; }
std::string defaults(std::string s) { return s; }
int compact(int n, int extra = default_number()) { return n + extra; }
std::string compact(std::string s) { return s; }
void produced(int n, int *out) { *out = n + 1; }
void produced(std::string s, double *out) { *out = s.size() + 0.5; }
int duplicate(int n) { return n; }
int duplicate(long n) { return (int)n; }
int conflicting(int n) { return n; }
std::string conflicting(long) { return "large"; }
class Choice {
public:
  Choice(int n, int extra = default_number()) : value(n + extra) {}
  Choice(std::string s) : value((int)s.size()) {}
  int pick(int n) { return n; }
  std::string pick(std::string s) { return s; }
  static int build(int n) { return n; }
  static std::string build(std::string s) { return s; }
  int value;
};
%}

%feature("director") DirectorChoice;
%typemap(pytyping) const DirectorChoice &, DirectorChoice * "DirectorChoice"
%inline %{
struct DirectorChoice {
  DirectorChoice() : value(1) {}
  DirectorChoice(int input_value, int extra = default_number()) : value(input_value + extra) {}
  DirectorChoice(const DirectorChoice &other) : value(other.value) {}
  virtual ~DirectorChoice() {}
  virtual int get() const { return value; }
  int value;
};
%}

%include <std_vector.i>
%template(StringVector) std::vector<std::string>;
%typemap(pytyping) const std::vector<std::string> & "typing.Sequence[str]"
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) const std::vector<std::string> & {
  $1 = PySequence_Check($input) && !PyUnicode_Check($input) && !PyBytes_Check($input);
}
%feature("python:stub:overloads", rank="-1") text_kind(const std::string &);
%feature("compactdefaultargs", "0") text_defaults;
%feature("python:stub:overloads", rank="5") text_defaults;
%feature("python:stub:overloads", rank="-1") text_defaults(const std::string &, int);
%feature("python:stub:overloads", rank="+7") same_rank;
%feature("python:stub:overloads", rank="-2147483648") min_rank;
%feature("python:stub:overloads", rank="2147483647") max_rank;
%inline %{
int text_kind(const std::vector<std::string> &items) { return (int)items.size(); }
std::string text_kind(const std::string &text) { return text; }
int text_defaults(const std::vector<std::string> &items, int extra = 2) { return (int)items.size() + extra; }
std::string text_defaults(const std::string &text, int extra = 2) { return text + std::string(extra, '!'); }
int same_rank(int value) { return value; }
int same_rank(bool value) { return value ? 17 : 0; }
int min_rank(int value) { return value; }
int min_rank(bool value) { return value ? 17 : 0; }
int max_rank(int value) { return value; }
int max_rank(bool value) { return value ? 17 : 0; }
%}

%typemap(default) int synthesized "$1 = 7;"
%inline %{
int typemap_default(int synthesized) { return synthesized; }
std::string typemap_default(std::string text) { return text; }
%}

// Cached overload annotations must use original %extend member names.
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
  static const char *qualified(const char *text) { (void)text; return "qualified"; }
  static int qualified(int value) { return value; }
  static const char *bare(const char *text) { (void)text; return "bare"; }
  static int bare(int value) { return value; }
  const char *instance(const char *text) { (void)text; return "instance"; }
  int instance(int value) { return value; }
}
