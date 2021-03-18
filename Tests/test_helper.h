#ifndef __UNITTESTS__TEST_HELPER_H
#define __UNITTESTS__TEST_HELPER_H

// to be used in tests
// just inline this code
extern "C" {
    #include "doh.h"
    #include "cparse.h"
    void __reset_parser();
}

namespace {

    void Swig_init_for_unittests() {
        Swig_init();
        Swig_cparse_cplusplus(1);        
    }

    template<class T>
    void print(T x) {
        DOH* output_as_str = DohStr(x);
        std::cout << (const char*)DohData(output_as_str) << "\n";        
    }

    template<class T>
    void print_content(T x) {
        print(x);
        size_t idx=0;
        std::cout << "-------------\n";
        for (
            auto iterator = DohFirst(x); // see DOH/README
            iterator.item;
            iterator = DohNext(iterator)
        ) {
            std::cout << "loop:" << idx<< "\n";
            std::cout << "::::::::::::::::\n";
            Node* x = iterator.item;
            print(x);
            idx++;
        }
        std::cout << "-------------\n";
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
    Node* get_first_with_symname(Node *n, const char* name) {
        return get_first(n, "sym:name", name);
    }
}

#endif
