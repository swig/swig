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

