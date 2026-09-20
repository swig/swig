%module xxx

// A string literal is an lvalue of array type, so a 'decltype(auto)' variable initialised by one is a
// reference to an array of characters.  The u8, u and U encoding prefixes give a literal one of the
// char8_t, char16_t and char32_t character types, none of which SWIG has a type for, so the variable is
// ignored rather than wrapped.

decltype(auto) dauto_string_utf8 = u8"text";
decltype(auto) dauto_string_char16 = u"text";
decltype(auto) dauto_string_char32 = U"text";

// A literal with no prefix is of char and a wide one of wchar_t, both of which are wrapped.
decltype(auto) dauto_string = "text";
decltype(auto) dauto_string_wide = L"text";

// Ordinary 'auto' deduces the 'const char *' the array decays to, which is wrapped as usual.
auto auto_string = "text";
