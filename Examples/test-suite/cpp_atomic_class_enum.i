%module cpp_atomic_class_enum

%inline {
    class MyClass {
        public:
            enum SomeEnum
            {
                FIRST_VALUE,
                SECOND_VALUE
            };
    };
}
