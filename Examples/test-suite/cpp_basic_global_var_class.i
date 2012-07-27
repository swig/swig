%module cpp_basic_global_var_class

%inline {
    class MyClass {};
    MyClass myGlobalClassInstance;
}
