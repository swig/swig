%module test_shadow

%feature("shadow") global_func %{
def global_func(a, b):
    print("SHADOW WORKS")
    return $action(a, b)
%}

%feature("shadow") shadowed_func %{
def shadowed_func(a, b):
    print("SHADOW WORKS")
    return $action(a, b)
%}

%inline %{
int global_func(int a, int b) { return a + b; }
int shadowed_func(int a, int b) { return a * b; }
int plain_func(int a, int b) { return a - b; }

#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}
