%module template_function_overload_kind

// %template instantiates only the function template overloads whose template parameters take the template arguments

%inline %{
template<class T> struct KindBox {
  T t;
};
typedef double KindReal;
enum KindColour { KindRed, KindGreen };
const int KindConstant = 6;

template<typename T> int kind() { return 1; }
template<int N> int kind() { return 2; }
template<typename T, typename U> int kind() { return 3; }
template<template<class> class TT> int kind() { return 4; }

template<typename T> T kindp(T t) { return t; }
template<int N> int kindp(int i) { return N + i; }

struct KindMember {
  template<typename T> int get() { return 1; }
  template<int N> int get() { return 2; }
};
%}

%{
#include <cstddef>
%}

// Non-type template parameters with a type not declared to SWIG
%inline %{
template<std::size_t N> int kindsize() { return (int)N; }
template<typename T, T V> T kindvalue() { return V; }
%}

%template(kind_int) kind<int>;
%template(kind_real) kind<KindReal>;
%template(kind_5) kind<5>;
%template(kind_constant) kind<KindConstant>;
%template(kind_red) kind<KindRed>;
%template(kind_int_double) kind<int, double>;
%template(kind_box) kind<KindBox>;

%template(kindp_double) kindp<double>;
%template(kindp_10) kindp<10>;

%template(kindsize_3) kindsize<3>;
%template(kindvalue_int_7) kindvalue<int, 7>;

%extend KindMember {
  %template(get_int) get<int>;
  %template(get_7) get<7>;
}
