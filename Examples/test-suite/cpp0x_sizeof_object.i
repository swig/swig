/* This testcase checks whether Swig correctly uses the sizeof() on the
   concrete objects and not only types introduced in C++0x. */
%module cpp0x_sizeof_object

%inline %{
struct B {
        unsigned long member1;
        long long member2;
        char member3;
};

struct A {
	B member;
};

const int a = sizeof(A::member);
%}
