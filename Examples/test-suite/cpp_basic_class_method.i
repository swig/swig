%module cpp_basic_class_method

%inline{
    class MyClass {
        public:
            int someMethod(void) {
                return 42;
            }
    };
}
