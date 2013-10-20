/* This testcase checks whether SWIG correctly parses alias templates. */
%module cpp11_template_typedefs

%warnfilter(SWIGWARN_CPP11_ALIAS_TEMPLATE) TypedefName;
%warnfilter(SWIGWARN_CPP11_ALIAS_DECLARATION) PF;

%inline %{
template< typename T1, typename T2, int >
class SomeType {
  T1 a;
  T2 b;
  int c;
};

// template aliasing
template< typename T2 >
using TypedefName = SomeType<char*, T2, 5>;

// type aliasing
typedef void (*PFD)(double);            // Old style
using PF = void (*)(double);            // New introduced syntax
%}

