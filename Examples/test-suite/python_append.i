/*
Testcase to test %pythonprepend and %pythonappend
*/

%module python_append 

%pythoncode %{
  import os.path
  mypath = os.path.dirname("/a/b/c/d.txt")
  funcpath = None
  staticfuncpath = None
  def grabpath():
    return funcpath
  def grabstaticpath():
    return staticfuncpath
%}

%pythonappend Test::func %{
    funcpath = os.path.dirname(funcpath)
%}

%pythonprepend Test::func %{
        global funcpath
        funcpath = mypath
%}

%pythonappend Test::static_func %{
staticfuncpath = os.path.basename(staticfuncpath)
pass   
%}

%pythonprepend Test::static_func {
    global staticfuncpath
    staticfuncpath = mypath
    pass
}

%inline %{

class Test {
public:
  static void static_func() {};
  void func() {};
};

%}

