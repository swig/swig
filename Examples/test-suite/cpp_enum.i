/*
The primary purpose of this testcase is to ensure that enums used along with the 'enum' keyword compile under c++.
*/

%module cpp_enum

%inline %{

#if __GNUC__ >= 5 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 8)
/* for anonymous enums */
/* dereferencing type-punned pointer will break strict-aliasing rules [-Werror=strict-aliasing] */
#pragma GCC diagnostic ignored "-Wstrict-aliasing"
#endif

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
{
 enum {Hi, Hello } hi;
}

%}

// Using true and false in enums is legal in C++. Quoting the standard:
// [dcl.enum]
//     ... The constant-expression shall be of integral or enumeration type.
// [basic.fundamental]
//     ... Types bool, char, wchar_t, and the signed and unsigned integer
//     types are collectively called integral types.
// So this shouldn't lead to a warning, at least in C++ mode.
%inline %{
typedef enum { PLAY = true, STOP = false } play_state;
%}

// Regression test for https://github.com/swig/swig/issues/2796
// Skip for C# as this enum can't be wrapper as a C# proper enum.
#if defined SWIGCSHARP || defined SWIGD
%ignore Enum2796;
#endif
%inline %{
typedef int mytype0;
typedef mytype0 mytype1;
#ifndef SWIG
typedef int unknown_to_swig_type;
#endif
typedef unknown_to_swig_type mytype2;

enum Enum2796
{
   CASE0A = (mytype0)10,
   CASE0B = mytype0(10),
   CASE0C = static_cast<mytype0>(10),
   CASE1A = (mytype1)10, // Used to fail
   CASE1B = mytype1(10),
   CASE1C = static_cast<mytype1>(10),
   CASE2A = (mytype2)10, // Used to fail
   CASE2B = mytype2(10),
   CASE2C = static_cast<mytype2>(10),
   CASE3A = (unknown_to_swig_type)10,
   CASE3B = unknown_to_swig_type(10),
   CASE3C = static_cast<unknown_to_swig_type>(10),
   CASE4A = (5)*2,
   CASE4B = (14)&11,
   CASE4C = (3)+7,
   CASE4D = (42)-32,
};
%}
