/* This testcase checks whether SWIG correctly parses and generates the code
   for variadic templates. This covers the variadic number of arguments inside
   the template brackets, new functions sizeof... and multiple inheritance
   using variadic number of classes.
*/
%module cpp11_variadic_templates
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
	    SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE,
	    SWIGWARN_RUBY_MULTIPLE_INHERITANCE) MultiInherit;
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
	    SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE,
	    SWIGWARN_RUBY_MULTIPLE_INHERITANCE) NumerousInherit;
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
	    SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE,
	    SWIGWARN_RUBY_MULTIPLE_INHERITANCE) LotsInherit;

#if defined SWIGGO
%warnfilter(SWIGWARN_LANG_NATIVE_UNIMPL) ParmsPtrRValueRef;
%warnfilter(SWIGWARN_LANG_NATIVE_UNIMPL) ParmsRValueRef;
#endif

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

%template (MultiArgs1) MultiArgs<int, std::vector<int>, std::map<std::string, std::vector<int>>>;

////////////////////////
// Variadic sizeof... //
////////////////////////
%inline %{
template<typename... Args> struct SizeOf {
  static const int size = sizeof...(Args);
};
%}

%template (SizeOf0) SizeOf<>;
%template (SizeOf1) SizeOf<int>;
%template (SizeOf2) SizeOf<int, int>;
%template (SizeOf3) SizeOf<int, int, int>;

//////////////////////////
// Variadic inheritance //
//////////////////////////
%inline %{
class A {
public:
  A() {
    a = 100;
  }
  virtual ~A() {}
  int a;
};

class B {
public:
  B() {
    b = 200;
  }
  virtual ~B() {}
  int b;
};

class C {
public:
  C() {
    c = 300;
  }
  virtual ~C() {}
  int c;
};

class D {
public:
  D() {
    d = 400;
  }
  virtual ~D() {}
  int d;
};

template <typename... BaseClasses> class MultiInherit : public BaseClasses... {
public:
  MultiInherit(BaseClasses&... baseClasses) : BaseClasses(baseClasses)... {}
  void MultiInstanceMethod(BaseClasses&... baseClasses) {}
  static void MultiStaticMethod(BaseClasses&... baseClasses) {}
  int InstanceMethod() { return 123; }
  static int StaticMethod() { return 456; }
};
%}

%template (MultiInherit0) MultiInherit<>;
%template (MultiInherit1) MultiInherit<A>;
%template (MultiInherit2) MultiInherit<A,B>;
%template (MultiInherit3) MultiInherit<A,B,C>;

%inline %{
template <typename... BaseClasses> class NumerousInherit : public BaseClasses... {
public:
  NumerousInherit(int i, BaseClasses&... baseClasses) : BaseClasses(baseClasses)... {}
  void NumerousInstanceMethod(int i, BaseClasses&... baseClasses) {}
  static void NumerousStaticMethod(int i, BaseClasses&... baseClasses) {}
  int InstanceMethod() { return 123; }
  static int StaticMethod() { return 456; }
};
%}

%template (NumerousInherit0) NumerousInherit<>;
%template (NumerousInherit1) NumerousInherit<A>;
%template (NumerousInherit2) NumerousInherit<A,B>;
%template (NumerousInherit3) NumerousInherit<A,B,C>;

%inline %{
template <typename T, typename... BaseClasses> class LotsInherit : public T, public BaseClasses... {
public:
  LotsInherit(T t, BaseClasses&... baseClasses) : BaseClasses(baseClasses)... {}
  void LotsInstanceMethod(T t, BaseClasses&... baseClasses) {}
  static void LotsStaticMethod(T t, BaseClasses&... baseClasses) {}
  int InstanceMethod() { return 123; }
  static int StaticMethod() { return 456; }
};
%}

%template (LotsInherit1) LotsInherit<A>;
%template (LotsInherit2) LotsInherit<A,B>;
%template (LotsInherit3) LotsInherit<A,B,C>;
%template (LotsInherit4) LotsInherit<A,B,C,D>;

%inline %{
struct KlassMemFuncs {
  int memfunc0() { return 0; }
  int memfunc1() { return 1; }
  int memfunc2() { return 2; }
  int memfunc3() { return 3; }
};
template <typename... V> struct VariadicParms {
  void ParmsVal(V... vparms_v) {}
  void ParmsPtr(V*... vparms_p) {}
  void ParmsPtrRef(V*&... vparms_pr) {}
  void ParmsPtrRValueRef(V*&&... vparms_rvr) {}
  void ParmsRef(V&... vparms_r) {}
  void ParmsRValueRef(V&&... vparms_r) {}
  void ParmsConstRef(const V&... vparms_cr) {}

  // Conventional unnamed parameter function ptr
  void ParmsFuncPtrVal(int (*)(V...)) {}
  void ParmsFuncPtrPtr(int (*)(V*...)) {}
  void ParmsFuncPtrPtrRef(int (*)(V*&...)) {}
  void ParmsFuncPtrPtrRValueRef(int (*)(V*&&...)) {}
  void ParmsFuncPtrRef(int (*)(V&...)) {}
  void ParmsFuncPtrRValueRef(int (*)(V&&...)) {}
  void ParmsFuncPtrConstRef(int (*)(const V&...)) {}

  // Unconventional unnamed parameter function ptr
  void ParmsFuncUnnamedVal(int (V...)) {}
  void ParmsFuncUnnamedPtr(int (V*...)) {}
  void ParmsFuncUnnamedPtrRef(int (V*&...)) {}
  void ParmsFuncUnnamedPtrRValueRef(int (V*&&...)) {}
  void ParmsFuncUnnamedRef(int (V&...)) {}
  void ParmsFuncUnnamedRValueRef(int (V&&...)) {}
  void ParmsFuncUnnamedConstRef(int (const V&...)) {}

  // Unconventional named parameter function ptr
  void ParmsFuncNamedVal(int fn(V...)) {}
  void ParmsFuncNamedPtr(int fn(V*...)) {}
  void ParmsFuncNamedPtrRef(int fn(V*&...)) {}
  void ParmsFuncNamedPtrRValueRef(int fn(V*&&...)) {}
  void ParmsFuncNamedRef(int fn(V&...)) {}
  void ParmsFuncNamedRValueRef(int fn(V&&...)) {}
  void ParmsFuncNamedConstRef(int fn(const V&...)) {}

  // Conventional unnamed parameter member function ptr
  void ParmsMemFuncPtrVal(int (KlassMemFuncs::*)(V...)) {}
  void ParmsMemFuncPtrPtr(int (KlassMemFuncs::*)(V*...)) {}
  void ParmsMemFuncPtrPtrRef(int (KlassMemFuncs::*)(V*&...)) {}
  void ParmsMemFuncPtrPtrRValueRef(int (KlassMemFuncs::*)(V*&&...)) {}
  void ParmsMemFuncPtrRef(int (KlassMemFuncs::*)(V&...)) {}
  void ParmsMemFuncPtrRValueRef(int (KlassMemFuncs::*)(V&&...)) {}
  void ParmsMemFuncPtrConstRef(int (KlassMemFuncs::*)(const V&...)) {}
};
%}

%template(VariadicParms0) VariadicParms<>;
%template(VariadicParms1) VariadicParms<A>;
%template(VariadicParms2) VariadicParms<A,B>;
%template(VariadicParms3) VariadicParms<A,B,C>;

%inline %{
template <typename... V> struct FixedAndVariadicParms {
public:
  void ParmsVal(short samename1, V... samename) {}
  void ParmsPtr(short shortvar, V*... vparms_p) {}
  void ParmsPtrRef(short shortvar, V*&... vparms_pr) {}
  void ParmsPtrRValueRef(short shortvar, V*&&... vparms_rvr) {}
  void ParmsRef(short shortvar, V&... vparms_r) {}
  void ParmsRValueRef(short shortvar, V&&... vparms_r) {}
  void ParmsConstRef(short shortvar, const V&... vparms_cr) {}

  void ParmsFuncPtrVal(short shortvar, int (*)(short, V...)) {}
  void ParmsMemFuncPtrVal(int (KlassMemFuncs::*)(V...)) {}
};
%}

%template(FixedAndVariadicParms0) FixedAndVariadicParms<>;
%template(FixedAndVariadicParms1) FixedAndVariadicParms<A>;
%template(FixedAndVariadicParms2) FixedAndVariadicParms<A,B>;
%template(FixedAndVariadicParms3) FixedAndVariadicParms<A,B,C>;

%inline %{
struct PlainStruct {
    template<typename ... VVV> void ParmsPlainStructVariadic(const VVV& ... args) {}
};
%}
%template(PlainStructParms0) PlainStruct::ParmsPlainStructVariadic<>;
%template(PlainStructParms1) PlainStruct::ParmsPlainStructVariadic<A>;
%template(PlainStructParms2) PlainStruct::ParmsPlainStructVariadic<A,B>;
%template(PlainStructParms3) PlainStruct::ParmsPlainStructVariadic<A,B,C>;
