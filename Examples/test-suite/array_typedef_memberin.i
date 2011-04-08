%module array_typedef_memberin
%inline %{ 
typedef short Eight[8]; 
typedef const short ConstEight[8]; 
namespace ArrayExample 
{ 
    class ExampleDetail 
    { 
    public: 
        Eight node_list; 
        const Eight node_list2; 
        ConstEight node_list3; 

        void fn1(Eight a) {}
        void fn2(const Eight a) {}
        void fn3(ConstEight a) {}

        void fn4(Eight* a) {}
        void fn5(ConstEight* a) {}
        void fn6(const ConstEight* a) {}

        void fn7(Eight*& a) {}
        void fn8(ConstEight*& a) {}
        void fn9(const ConstEight*& a) {}
    };
} 

typedef int Four[4];
typedef const int ConstFour[4];

void test_1(int (*v)[4]) {}
void test_2(Four *v) {}
void test_3(const Four *v) {}
void test_4(ConstFour *v) {}
void test_5(const int (*v)[4]) {}
void test_3r(const Four *&v) {}
void test_4r(ConstFour *&v) {}
%} 
