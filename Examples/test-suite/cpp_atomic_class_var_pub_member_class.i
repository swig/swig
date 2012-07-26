%module cpp_atomic_class_var_pub_member_class

%inline{
    class MyClass {
    };
    class MySecondClass {
        public:
            MyClass myPubClassInstance;
    };
}
