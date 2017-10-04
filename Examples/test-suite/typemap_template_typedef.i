%module typemap_template_typedef
//%module("templatereduce") typemap_template_typedef

%typemap(in) int TMAP55 %{ $1 = 55; /* int TMAP55 typemap */ %}
%typemap(in) int TMAP66 %{ $1 = 66; /* int TMAP66 typemap */ %}
%typemap(in) int TMAP77 %{ $1 = 77; /* int TMAP77 typemap */ %}
%typemap(in) int TMAP88 %{ $1 = 88; /* int TMAP88 typemap */ %}

%apply int TMAP77 { XXX<int>::Long cc }

%inline %{
typedef int MyInteger;

template<typename T> struct XXX {
#ifdef SWIG
// In swig-3.0.12 'Long aa' was actually stored as 'long aa' in typemap table instead of 'XXX<int>::Long aa'
%apply int TMAP55 { Long aa }
%apply int TMAP66 { XXX<int>::Long bb }
%apply int TMAP88 { XXX<MyInteger>::Long dd }
#endif
  typedef long Long;
  long aa1(long aa) { return aa; }
  long aa2(Long aa) { return aa; }
  long bb1(long bb) { return bb; }
  long bb2(Long bb) { return bb; }
  long cc1(long cc) { return cc; }
  long cc2(Long cc) { return cc; }
  long dd1(long dd) { return dd; }
  long dd2(Long dd) { return dd; }
#ifdef SWIG
%clear Long aa;
%clear XXX<int>::Long bb;
%clear XXX<MyInteger>::Long dd;
#endif
  long aa3(Long aa) { return aa; }
  long bb3(Long bb) { return bb; }
  long cc3(Long cc) { return cc; }
  long dd3(Long dd) { return dd; }
};
%}

%template(XXXInt) XXX<MyInteger>;

%clear XXX<int>::Long cc;

%inline %{
  long aa1(XXX<int>::Long aa) { return aa; }
  long aa2(long aa) { return aa; }
  long bb1(XXX<int>::Long bb) { return bb; }
  long bb2(long bb) { return bb; }
  long cc1(XXX<int>::Long cc) { return cc; }
  long cc2(long cc) { return cc; }
  long dd1(XXX<MyInteger>::Long dd) { return dd; }
  long dd2(long dd) { return dd; }
%}

%inline %{
typedef MyInteger MY_INTEGER;
template<typename T1, typename T2 = MY_INTEGER> struct YYY {
  void meff(T1 t1, T2 t2) {}
};
%}
%template(YYYIntInt) YYY<MY_INTEGER>;
%inline %{
  void whyohwhy(YYY<MY_INTEGER> yy) {}
%}
