/*
Testcase to test %pythonprepend and %pythonappend %pythoncode %pythonbegin
*/

%module python_append 

%pythoncode %{
mypath = os.path.dirname("/a/b/c/d.txt")
funcpath = None
staticfuncpath = None
def grabpath():
    return funcpath
def grabstaticpath():
    return staticfuncpath
def clearstaticpath():
    global staticfuncpath
    staticfuncpath = None
%}

%pythonappend Test::funk %{
funcpath = os.path.dirname(funcpath)
%}

%pythonprepend Test::funk %{
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

%pythonbegin %{
import os.path
%}

%inline %{
class Test {
public:
  static void static_func() {};
  void funk() {};
};
%}

// Github issue #1674
%extend ForSlots {
  %pythoncode %{
        __slots__ = ["this"]
    %}
}
// While __slots__ does not contain 'ValidVariable' in the list, it is still possible
// to set 'ValidVariable'. A little odd, but the whole attribute setting is bypassed
// for setting C/C++ member variables.
// Not sure how to test the equivalent for -builtin.
%inline %{
struct ForSlots {
  int ValidVariable;
  ForSlots() : ValidVariable(99) {}
};
%}

%inline %{
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}

