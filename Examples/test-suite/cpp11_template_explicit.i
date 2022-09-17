/* This unit tests whether SWIG correctly parses the code and makes wrappers
   for the new C++11 extern templates (explicit template instantiation without
   using the translation unit).
*/
%module cpp11_template_explicit

/* Suppress SWIG warnings related to explicit template instantiation and extern templates */
#pragma SWIG nowarn=SWIGWARN_PARSE_EXPLICIT_TEMPLATE
#pragma SWIG nowarn=SWIGWARN_PARSE_EXTERN_TEMPLATE

%inline %{

template<typename T> class Temper {
public:
  T valu;
};

class A {
public:
  int member;
  int memberFunction() { return 100; }
};

class B {
public:
  short member;
  short memberFunction() { return 100; }
};

template class Temper<A>;
extern template class Temper<B>;

template class Temper<A*>;
extern template class Temper<B*>;

template class Temper<int>;
extern template class Temper<short>;

/* Templated function to check support for extern template functions */
template <typename T>
T my_templated_function(int a, double b)
{
  return T();
}

/* Explicit extern function template instantiation with simple type */
extern template int my_templated_function<int>(int, double);
template int my_templated_function<int>(int, double);

/* Explicit extern function template instantiation with more complex types */
extern template A my_templated_function<A>(int, double);
template A my_templated_function<A>(int, double);

extern template Temper<int> my_templated_function<Temper<int>>(int, double);
template Temper<int> my_templated_function<Temper<int>>(int, double);

%}

%template(TemperInt) Temper<int>;

/* Enable several versions of the templated function */
%template(my_templated_function_int      ) my_templated_function<int>;
%template(my_templated_function_A        ) my_templated_function<A>;
%template(my_templated_function_TemperInt) my_templated_function<Temper<int>>;
