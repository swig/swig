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
#if 0
    {
        print(top);
        Node *classes = DohGetattr(top, "classes");
        for (
            auto iterator = DohFirst(classes); // see DOH/README
            iterator.item;
            iterator = DohNext(iterator)
        ) {
            std::cout << "loop:\n";
            Node* myclass = iterator.item;
            print(myclass);
        }
    }
#endif

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
    
    char code[] = R"(
        template<class T>
        struct TestStruct { 
            T x;
        };
        //%template(IntTestStruct) TestStruct<int>;
        //%template(FloatTestStruct) TestStruct<float>;
    )";
    DOH* codefile = DohNewFileFromFile(fmemopen(code, sizeof(code), "r"));
    Node *top = Swig_cparse(codefile);

    Node* mystruct = get_first_with_name(top, "TestStruct");
    print(mystruct);
}

