%module constructor_copy

%copyctor;
%nocopyctor Foo8;
%nocopyctor Bar<double>;

%inline %{
  
struct Foo1 {
  int x;

  Foo1(int _x = 2) : x(_x)
  {
  }  
};

struct Foo2 {
  Foo2() { }
};

struct Foo3 {
  Foo3() { }
  Foo3(const Foo3& ) { }
};

struct Foo4 {
  Foo4() { }
  
protected:
  Foo4(const Foo4& ) { }
};


struct Foo4a {
  Foo4a() { }
  
private:
  Foo4a(const Foo4a& ) { }
};


struct Foo5 : Foo4 {
};

struct Foo6 : Foo4 {
  Foo6(const Foo6& ) { }
};

struct Foo7 : Foo5 {
};

struct Foo8 {
};

template <class T>
class Bar 
{
public:
  int x;

  Bar(int _x = 0) : x(_x)
  {
  }
};
%}

%template(Bari) Bar<int>;
%template(Bard) Bar<double>;


#if defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGUTL)


%include "std_vector.i"

#if defined(SWIGCSHARP)
SWIG_STD_VECTOR_SPECIALIZE_MINIMUM(Flow, Space::Flow)
#endif

#if defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGPYTHON)
#define SWIG_GOOD_VECTOR
%ignore std::vector<Space::Flow>::vector(size_type);
%ignore std::vector<Space::Flow>::resize(size_type);
#endif

#if defined(SWIGTCL) || defined(SWIGPERL) || defined(SWIGRUBY) 
#define SWIG_GOOD_VECTOR
/* here, for languages with bad declaration */
%ignore std::vector<Space::Flow>::vector(unsigned int);
%ignore std::vector<Space::Flow>::resize(unsigned int);
#endif

%copyctor;


%inline %{

namespace Space {
class Flow {
public:
  Flow(int i) {}
};
}

%}

%template (VectFlow) std::vector<Space::Flow>;

#endif


