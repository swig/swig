%module cpp_basic_class_var_pub_member_atom

%inline{
    class MyClass {
        public:
            int myPubInt;
            MyClass() : myPubInt(42){}
    };
}
