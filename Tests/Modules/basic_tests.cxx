#include "catch.hpp"
#include <iostream>
#include "test_helper.h"
extern "C" {
    #include "doh.h"
    #include "cparse.h"
}

TEST_CASE( "Code_w_o_templates", "[Modules]" ) {
    Swig_init();
    
    char code[] = "struct TestStruct { int x; };\nint f() { return 2; }\n";
    DOH* codefile = DohNewFileFromFile(fmemopen(code, sizeof(code), "r"));

    Node *top = Swig_cparse(codefile);

    Node* mystruct = get_first_of_kind(top, "struct");
    CHECK( get_attr(mystruct, "name") == "TestStruct" );

    Node* mystruct2 = get_first_with_name(top, "TestStruct");
    CHECK( get_attr(mystruct2, "kind") == "struct" );
    CHECK( mystruct == mystruct2 );

    Node* myfunc = get_first_of_kind(top, "function");
    CHECK( get_attr(myfunc, "name") == "f" );
}

TEST_CASE( "Code_with_simple_templates", "[Modules]" ) {
    Swig_init();
    Swig_cparse_cplusplus(1);

    char code[] = R"(
        template<class MyT>
        struct TestStruct { 
            MyT x;
        };
        %template(IntTestStruct) TestStruct<int>;
        %template(FloatTestStruct) TestStruct<float>;
    )";
    DOH* codefile = DohNewFileFromFile(fmemopen(code, sizeof(code), "r"));
    Node *top = Swig_cparse(codefile);

    Node *classes = DohGetattr(top, "classes");

    Node* myStruct = get_first_with_symname(classes, "TestStruct");
    Node* myFloatStruct = get_first_with_symname(classes, "FloatTestStruct");
    Node* myIntStruct = get_first_with_symname(classes, "IntTestStruct");

    REQUIRE(myStruct != nullptr);
    REQUIRE(myFloatStruct != nullptr);
    REQUIRE(myIntStruct != nullptr);

    CHECK(get_attr(myIntStruct, "name") == "TestStruct<(int)>");
    CHECK(get_attr(myFloatStruct, "name") == "TestStruct<(float)>");
}

