#include "catch.hpp"
#include <string>
extern "C" {
    #include "doh.h"
}

TEST_CASE( "First_Steps", "[DOH]" ) {
    DOHconst_String_or_char_ptr text = "Hello World";
    DOH* obj = DohStr(text);

    // compare sizof(int) bytes of text and obj:
    // (must be different)
    CHECK(
        reinterpret_cast<const int*>(obj)[0] !=
        reinterpret_cast<const int*>(text)[0]
    );

    // use DohData to get raw string info back
    CHECK(
        std::string(reinterpret_cast<const char*>(DohData(obj))) ==
        std::string(reinterpret_cast<const char*>(text))
    );

    // however the obj has its own memory
    CHECK(
        reinterpret_cast<const char*>(DohData(obj)) !=
        reinterpret_cast<const char*>(text)
    );

}