#include "catch.hpp"
#include <iostream>
extern "C" {
    #include "doh.h"
    #include "cparse.h"
}

namespace {
    template<class T>
    void print(T x) {
        DOH* output_as_str = DohStr(x);
        std::cout << (const char*)DohData(output_as_str) << "\n";        
    }
    std::string get_attr(Node* node, const char* name) {
        DOH* attr = DohGetattr(node, name);  
        DOH* output_as_str = DohStr(attr);
        return std::string((const char*)DohData(output_as_str));
    }

    Node* get_first(Node *n, const char* attr_name, const char* v) {
        for (
            auto iterator = DohFirst(n); // see DOH/README
            iterator.item;
            iterator = DohNext(iterator)
        ) {
            Node* x = iterator.item;
            if (get_attr(x,attr_name) == v) {
                return x;
            }
        }
        return nullptr;
    }

    Node* get_first_of_kind(Node *n, const char* kind) {
        return get_first(n, "kind", kind);
    }
    Node* get_first_with_name(Node *n, const char* name) {
        return get_first(n, "name", name);
    }
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
