%module xxx

// Adjacent string literals make one literal, named by the one prefix that gives it its character type.
decltype(auto) utf8_joined = u8"one" u8"two";
decltype(auto) utf16_joined = u"one" u"two" u"three";
decltype(auto) raw_then_utf8 = R"(one)" u8"two";
decltype(auto) utf8_then_raw = u8"one" R"(two)";
decltype(auto) raw_utf32_first = UR"(one)" "two" U"three";
