/*
The primary purpose of this testcase is to ensure that enums used along with the 'enum' keyword compile under c++.
*/

%module cpp_enum

%inline %{

enum SOME_ENUM {ENUM_ONE, ENUM_TWO};

struct StructWithEnums {
    StructWithEnums() : some_enum(ENUM_ONE) {};
    enum SOME_ENUM some_enum;
    void enum_test1(enum SOME_ENUM param1, enum SOME_ENUM* param2, enum SOME_ENUM& param3) {};
    void enum_test2(SOME_ENUM param1, SOME_ENUM* param2, SOME_ENUM& param3) {};

    SOME_ENUM enum_test3() { return ENUM_ONE; };
    enum SOME_ENUM enum_test4() { return ENUM_TWO; };

    SOME_ENUM* enum_test5() { return &some_enum; };
    enum SOME_ENUM* enum_test6() { return &some_enum; };

    SOME_ENUM& enum_test7() { return some_enum; };
    enum SOME_ENUM& enum_test8() { return some_enum; };
};


 struct Foo
 {   
   enum {Hi, Hello } hola;
   
   Foo() 
     : hola(Hello)
   {
   }
 };

extern "C"
 enum {Hi, Hello } hi;

%}
