/*
Testcase to test %pythonprepend and %pythonappend
*/

%module python_append 

%pythonappend Test::func %{
    pass
%}

%pythonprepend Test::func %{
        pass
%}

%pythonappend Test::static_func %{
pass   
%}

%pythonprepend Test::static_func {
    pass
}

%inline %{

class Test {
public:
  static void static_func() {};
  void func() {};
};

%}

