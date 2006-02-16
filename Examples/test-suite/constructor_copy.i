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



%{
#include <vector>
%}

namespace std {
    
  template<class T> class vector {
  public:
    typedef size_t size_type;
    typedef T value_type;
    typedef const value_type& const_reference;
    vector();
    vector(size_type n);
  };
}

    
  
%copyctor;

//%ignore std::vector<Space::Flow>::vector(size_type); 
%ignore std::vector<Space::Flow>::resize(size_type); 
//Ignore as Flow does not have a default constructor

%inline %{

namespace Space {
class Flow {
public:
  Flow() {}
  Flow(int i) {}
  Flow(const Flow& other) {}
};
}

%}

%template (VectFlow) std::vector<Space::Flow>;
