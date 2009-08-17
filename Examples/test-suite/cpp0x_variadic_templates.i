/* This testcase checks whether Swig correctly parses and generates the code
   for variadic templates. This covers the variadic number of arguments inside
   the template brackets, new functions sizeof... and multiple inheritance
   using variadic number of classes.
*/
%module cpp0x_variadic_templates
%warnfilter(507) MultiArgs1;
%warnfilter(507) SizeOf1;
%warnfilter(507) MultiInherit1;

////////////////////////
// Variadic templates //
////////////////////////
%inline %{
#include <vector>
#include <string>
#include <map>

template<typename... Values>
class MultiArgs {
};

class MultiArgs<int, std::vector<int>, std::map<std::string, std::vector<int>>> multiArgs;

%}

// TODO
%template (MultiArgs1) MultiArgs<int, std::vector<int>, std::map<std::string, std::vector<int>>>;

////////////////////////
// Variadic sizeof... //
////////////////////////
%inline %{
template<typename... Args> struct SizeOf {
  static const int size = sizeof...(Args);
};
%}

// TODO
%template (SizeOf1) SizeOf<int, int>;

//////////////////////////
// Variadic inheritance //
//////////////////////////
%inline %{
class A {
public:
        A() {
                a = 100;
        }
        
        int a;
};

class B {
public:
        B() {
                b = 200;
        }
        int b;
};

template <typename... BaseClasses> class MultiInherit : public BaseClasses... {
public:
   MultiInherit(BaseClasses&... baseClasses) : BaseClasses(baseClasses)... {}
};
%}

// TODO
%template (MultiInherit1) MultiInherit<A,B>;
