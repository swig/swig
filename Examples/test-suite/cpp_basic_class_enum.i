%module cpp_basic_class_enum

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
