/*
The primary purpose of this testcase is to ensure that enums used along with the 'enum' keyword compile under c++.
*/

%module cpp_enum

%inline %{

enum SOME_ENUM {ENUM_ONE, ENUM_TWO};

typedef struct {
    enum SOME_ENUM some_enum;
    void enum_test1(enum SOME_ENUM* param1) {};
    void enum_test2(SOME_ENUM param1) {};
    SOME_ENUM enum_test3() { return ENUM_ONE; };
    enum SOME_ENUM enum_test4() { return ENUM_TWO; };
} StructWithEnums;

%}
