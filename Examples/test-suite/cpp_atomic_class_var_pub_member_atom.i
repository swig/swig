%module cpp_atomic_class_var_pub_member_atom

%inline{
    class MyClass {
        public:
            int myPubInt;
            MyClass() : myPubInt(42){}
    };
}
