%module xxx

%include <std_wstring.i>

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

// Ordinary 'auto' deduces the pointer the array decays to, which is const for a narrow and a wide literal
// alike - warning 451 names 'const char *' and warning 455 'const wchar_t *'.
auto auto_string = "text";
auto auto_string_wide = L"text";

// A prefixed literal is ignored for ordinary 'auto' too, the pointer it decays to being one to a character
// type SWIG has no type for.  Adjacent literals concatenate into one literal carrying the prefix.
auto auto_string_utf8 = u8"text";
auto auto_string_char16 = u"text";
auto auto_string_char32 = U"text";
auto auto_string_joined = "text" u8"more";

// A reference binds to the array of characters itself, so these are wrapped as references to arrays.
auto& ref_string = "text";
auto&& fwd_string = "text";
const auto& cref_string = "text";
auto& ref_string_wide = L"text";

// A prefixed literal is ignored, as is a braced literal, whose length is not known, and a volatile reference.
auto& ref_string_utf8 = u8"text";
auto&& braced_string{"text"};
volatile auto& vref_string = "text";
