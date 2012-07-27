%module cpp_basic_namespaced_class
%feature (nspace, "1");

%inline{
    namespace myNamespace {
        class MyClass {
        };
    }
}
