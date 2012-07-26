%module cpp_atomic_class_method

%inline{
    class MyClass {
        public:
            int someMethod(void) {
                return 42;
            }
    };
}
