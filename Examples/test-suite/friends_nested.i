%module friends_nested

// Issue #2845 - handling friends in nested classes

#pragma SWIG nowarn=SWIGWARN_PARSE_UNNAMED_NESTED_CLASS
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) CPP17::AA::BB::more_acc_cond::squeezed_in;

%rename(operatorshift) operator<<;
%rename(operatorshift) *::operator<<;

%feature("flatnested") spot::acc_cond::mark_t;

%inline %{
#include <iostream>

std::ostream& std_cout_reference() {
  return std::cout;
}

// Stops cout from outputting anything
void std_cout_badbit() {
  std_cout_reference().setstate(std::ios_base::badbit);
}

namespace spot
{
  class option_map
  {
  public:
    friend std::ostream& operator<<(std::ostream& os, const option_map& m); // 1
  };

  class acc_cond
  {
  public:
    struct mark_t
    {
      mark_t operator<<(unsigned i) const; // 2
      friend std::ostream& operator<<(std::ostream& os, mark_t m); // 3
    };
  };

  std::ostream& operator<<(std::ostream& os, const acc_cond& acc); // 4
}

void test_from_cplusplus() {
  spot::option_map om;
  {
    using namespace spot;
    operator<<(std::cout, om);
  }

  spot::acc_cond::mark_t m;
  m.operator<<(999);
  {
    using namespace spot;
    operator<<(std::cout, m);
  }

  spot::acc_cond a;
  operator<<(std::cout, a);
}
%}

%{
namespace spot {
  std::ostream& operator<<(std::ostream& os, const option_map& m) { os << "operator<< 1" << std::endl; return os; } // 1
  acc_cond::mark_t acc_cond::mark_t::operator<<(unsigned i) const { std::ostream& os = std_cout_reference(); os << "operator<< 2" << std::endl; return spot::acc_cond::mark_t(); } // 2
  std::ostream& operator<<(std::ostream& os, acc_cond::mark_t m) { os << "operator<< 3" << std::endl; return os; }  // 3
  std::ostream& operator<<(std::ostream& os, const acc_cond& acc) { os << "operator<< 4" << std::endl; return os; } // 4
}
%}

%{
// Compiler using traditional (non-C++17 nested) namespaces
namespace CPP17 {
namespace AA {
namespace BB {
  class more_acc_cond {
  public:
   struct squeezed_in {
    struct more_mark_t
    {
      more_mark_t operator<<(unsigned i) const; // 6
      friend std::ostream& operator<<(std::ostream& os, const more_mark_t& m); // 5
    };
   };
  };
}
}
}
%}

// SWIG testing C++17 nested namespaces
namespace CPP17::AA::BB {
  class more_acc_cond {
  public:
   struct squeezed_in {
    struct more_mark_t
    {
      more_mark_t operator<<(unsigned i) const; // 6
      friend std::ostream& operator<<(std::ostream& os, const more_mark_t& m); // 5
    };
   };
  };
}

%{
namespace CPP17 {
namespace AA {
namespace BB {
  more_acc_cond::squeezed_in::more_mark_t more_acc_cond::squeezed_in::more_mark_t::operator<<(unsigned i) const { std::ostream& os = std_cout_reference(); os << "operator<< 6" << std::endl; return more_acc_cond::squeezed_in::more_mark_t(); }
  std::ostream& operator<<(std::ostream& os, const more_acc_cond::squeezed_in::more_mark_t& m) { os << "operator<< 5" << std::endl; return os; } // 5
}
}
}
%}


%inline %{
#if defined(SWIG)
#define STATIC_FOR_ANONYMOUS
#else
// For gcc in C++98 mode (at least) to avoid:
// error: unnamed type with no linkage used to declare variable ‘<unnamed class> instance’ with linkage 
#define STATIC_FOR_ANONYMOUS static
#endif
struct BaseForAnon {
    virtual ~BaseForAnon() {}
};

// Unnamed nested classes are ignored but were causing code that did not compile
STATIC_FOR_ANONYMOUS class /*unnamed*/ : public BaseForAnon {
  int member_var;
public:
  friend int myfriend();

  // nested unnamed class
  class /*unnamed*/ {
    int inner_member_var;
  public:
    // below caused SWIG crash
    friend int innerfriend();
  } anon_inner;

} instance;

// friend members ignored too as the entire unnamed class is ignored!
int myfriend() {
  return instance.member_var;
}
int innerfriend() {
  return instance.anon_inner.inner_member_var;
}
%}

///////////////////////////////////////////////////////////////
// Test nested templates and classes
///////////////////////////////////////////////////////////////

// %feature("flatnested"); // This ought to work for languages that don't support nested structs, but InnerInnerStruct is multiply defined at the time of writing
#if defined(SWIGJAVA) || defined(SWIGCSHARP)

%inline %{
namespace OuterSpace {
namespace InnerSpace {
struct OuterClass {
  template<typename T> struct InnerTemplate {
    InnerTemplate(T i) : val(i) {}
    void InstanceMethod(T i) {}
    static void StaticMethod(T i) {}
    friend T friendly(InnerTemplate/*<T>*/ t) {return t.val; }
    T thung(InnerTemplate/*<T>*/ t) {return t.val; }

    struct InnerInnerStruct {
      InnerInnerStruct(T p) : priv(p) {}
      friend T friendly_inner_qualified(const InnerTemplate<T>::InnerInnerStruct& i) { return i.priv; }
//      friend T friendly_inner(const InnerInnerStruct& i) { return i.priv; } // TODO: without template parameters
      void dosomething(const InnerInnerStruct& x) {}
      void useinner(const InnerTemplate& x) {}
    private:
      T priv;
    };

    void use_inner_inner(InnerInnerStruct iis) {}

    template<typename X> struct InnerInnerTemplate {
      InnerInnerTemplate(T t, X x) : t_private(t), x_private(x) {}
      friend X friendly_inner_x(const InnerTemplate<T>::InnerInnerTemplate<X>& i) { return i.x_private; }
      friend T friendly_inner_t(const InnerTemplate<T>::InnerInnerTemplate<X>& i) { return i.t_private; }
      void doanything(const InnerInnerTemplate& x) {}
      void useT(const T& ttt) {}
      void useX(const X& xxx) {}
      struct VeryInner {
        VeryInner(const T& t, const X& x) {}
        friend X very_inner(const InnerTemplate<T>::InnerInnerTemplate<X>::VeryInner& vi) { return 0; }
      };
    private:
      T t_private;
      X x_private;
    };

  private:
    T val;
  };
#if defined(SWIG)
  // Template instantation within the class
  %template(InnerDouble) InnerTemplate<double>;
  %template(InnerShort) InnerTemplate<short>;
#endif
};
}
}
%}

%extend OuterSpace::InnerSpace::OuterClass {
  // Template instantation after the class is fully defined and added to the symbol tables
  %template(InnerInt) InnerTemplate<int>;
}


%extend OuterSpace::InnerSpace::OuterClass::InnerTemplate<double> {
  %template(InnerInnerBool) InnerInnerTemplate<bool>;
}
%extend OuterSpace::InnerSpace::OuterClass::InnerTemplate<int> {
  %template(InnerInnerChar) InnerInnerTemplate<char>;
}
%extend OuterSpace::InnerSpace::OuterClass::InnerTemplate<short> {
  %template(InnerInnerString) InnerInnerTemplate<char *>;
}

#endif
