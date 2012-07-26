%module cpp_atomic_global_var_class

%inline {
    class MyClass {};
    MyClass myGlobalClassInstance;
}
