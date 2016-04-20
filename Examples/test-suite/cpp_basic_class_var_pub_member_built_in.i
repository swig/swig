%module cpp_basic_class_var_pub_member_built_in

%inline{
    class MyClass {
        public:
            int myPubInt;
            MyClass() : myPubInt(42){}
    };
}
