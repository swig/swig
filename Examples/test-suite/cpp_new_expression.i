%module cpp_new_expression

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) new_with_parens;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) new_bare;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) new_array;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) new_empty_parens;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) new_multi_a;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) new_multi_b;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) new_global;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) new_offset;

%inline %{
#include <utility>

struct Widget {
  int w;
  Widget() : w(7) {}
  Widget(int a, int b) : w(a + b) {}
};

// A new-expression as an initializer, with an ordinary declaration after each that must still be seen.
int *new_with_parens = new int(5);
int after_parens = 1;

Widget *new_bare = new Widget;
int after_bare = 2;

int *new_array = new int[10];
int after_array = 3;

Widget *new_empty_parens = new Widget();
int after_empty_parens = 5;

int *new_multi_a = new int(1), *new_multi_b = new int(2);
int after_multi = 6;

int *new_global = ::new int(8);
int after_global = 9;

// A new-expression that is only part of the initialiser.
int *new_offset = new int[3] + 1;
int after_offset = 10;

// A new-expression as a default argument, including a template argument list and a parameter after it.
int default_with_parens(int *p = new int(5)) { int v = *p; delete p; return v; }
int default_bare(Widget *w = new Widget) { int v = w->w; delete w; return v; }
int default_args(Widget *w = new Widget(1, 2)) { int v = w->w; delete w; return v; }
int default_array(int *a = new int[3]()) { int v = a[0] + a[2]; delete[] a; return v; }
int default_global(int *p = ::new int(6)) { int v = *p; delete p; return v; }
int default_offset(int *p = new int[3]() + 1) { int v = *p; delete[] (p - 1); return v; }
int default_template(std::pair<int, int> *p = new std::pair<int, int>(3, 4), int q = 10) {
  int v = p->first + p->second + q;
  delete p;
  return v;
}

%}

// The text of a new-expression default argument is compiled into the wrapper with compactdefaultargs.
%feature("compactdefaultargs") compact_defaults;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) compact_defaults;

%inline %{
int compact_defaults(int *a = new int[2] + 1, const Widget *w = new const Widget(2, 3),
                     std::pair<int, int> *p = new std::pair<int, int>(4, 5)) {
  *a = 3;
  int v = *a + w->w + p->first + p->second;
  delete[] (a - 1);
  delete w;
  delete p;
  return v;
}

// 'new' inside a function body, which SWIG skips over, is unaffected.
inline Widget *make_widget() { return new Widget; }
%}

// 'new' is only a keyword where it starts a new-expression, so it can still be a name in a directive.
%warnfilter(SWIGWARN_PARSE_KEYWORD) NewNames::create;
%rename(new) NewNames::create;
// The C backend would name a default constructor 'NewNames_new' too.
%nodefaultctor NewNames;

%inline %{
struct NewNames {
  static int create() { return 11; }
};
%}

#if !defined(SWIGC)
// TODO: the C backend emits a constant as a macro, so one named 'new' breaks its C++ header.
%warnfilter(SWIGWARN_PARSE_KEYWORD, SWIGWARN_RUBY_WRONG_NAME) new;
%constant int new = 12;
#endif

#if !defined(SWIGC) && !defined(SWIGCSHARP) && !defined(SWIGD) && !defined(SWIGJAVA)
// TODO: a keyword given as a %template name is not renamed as other names are.
%warnfilter(SWIGWARN_PARSE_KEYWORD) NewMaker::make<int>;
%inline %{
struct NewMaker {
  template<class T> static T make(T t) { return t; }
};
%}

%extend NewMaker {
  %template(new) make<int>;
}
#endif
