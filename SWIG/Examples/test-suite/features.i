%module features


// This testcase checks that %feature is working for templates and non user supplied constructors/destructors

// If the default %exception is used it will not compile. It shouldn't get used.
%exception "this_will_not_compile";

// Test 1: Test for no user supplied constructors and destructor
%exception Simple::Simple() "$action /*Simple::Simple*/";
%exception Simple::~Simple() "$action /*Simple::~Simple*/";

%inline %{
class Simple {};
%}


%exception NS::SimpleNS::SimpleNS() "$action /*Simple::Simple*/";
%exception NS::SimpleNS::~SimpleNS() "$action /*Simple::~Simple*/";

%inline %{
  namespace NS 
  {
    
    class SimpleNS {};
  }
  
%}

// Test 2: Test templated functions
%exception foobar "caca";
%exception foobar<int>(int) "$action /*foobar<int>*/";

%inline %{
template<class T> void foobar(T t) {}
%}

%template(FooBarInt) foobar<int>;

// Test 3: Test templates with no user supplied constructors and destructor
%exception SimpleTemplate<int>::SimpleTemplate() "$action /*SimpleTemplate<int>::SimpleTemplate<int>*/";
%exception SimpleTemplate<int>::~SimpleTemplate() "$action /*SimpleTemplate<int>::~SimpleTemplate*/";

%inline %{
template<class T> class SimpleTemplate {
 public:
};
 
%}

%template(SimpleInt) SimpleTemplate<int>;

// Test 4: Test templates with user supplied constructors and destructor
%exception Template<int>::Template() "$action /*Template<int>::Template<int>*/";
%exception Template<int>::Template(const Template&) "$action /*Template<int>::Template<int>(const Template&)*/";
%exception Template<int>::~Template() "$action /*Template<int>::~Template*/";
%exception Template<int>::foo "$action /*Template<int>::foo*/";

%inline %{
template<class T> class Template {
public:
  Template(){}

  Template(const Template&){}
  ~Template(){}
  void foo(){}
};
%}

%template(TemplateInt) Template<int>; 


%exception {
  $action // default %exception
}


%newobject One::getSquare() const; 

%inline %{

struct Square
{
  Square(int)
  {
  } 
};
  
struct One {
  Square *getSquare() const { return new Square(10); }
};
%}

%newobject Two::getSquare(); 

%inline %{
struct Two {
  Square *getSquare() const { return new Square(10); }
};

char *foo() {return 0;}
 
%}



%exception std::Vector::get {
  $action; // get %exception
}

%inline %{

namespace std {
    
    template<class T> class Vector {
      public:
        void push_back(const T& x) {}
#ifdef SWIG
        %extend {
            T& get(int i) {
                throw 1;
            }
        }
#endif
    };
}

%}

%template(VectorInt) std::Vector<int>;



%ignore TROOT::TROOT(const char *name, const char *title, void *initfunc = 0);
%inline %{
  class TROOT {
   
  public:
    TROOT()
    {
    }
    
    TROOT(const char *name, const char *title, void *initfunc = 0)
    {
    }
    
  };
%}
