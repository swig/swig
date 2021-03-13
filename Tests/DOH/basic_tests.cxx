#include "catch.hpp"
extern "C" {
    #include "doh.h"
}

TEST_CASE( "Strings", "[DOH]" ) {
    GIVEN( "A C-string with 'Hello World'" ) {
        DOHconst_String_or_char_ptr text = "Hello World";
        WHEN( "An DOH object is created from the string" ) {
            DOH* obj = DohStr(text);
            THEN( "The obj does not start with the first char of the string" ) {
                CHECK( *reinterpret_cast<const char*>(obj) != *reinterpret_cast<const char*>(text));
            } 
        }
    }
}