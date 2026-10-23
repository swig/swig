%module xxx

%include <std_wstring.i>

// The u8, u and U prefixes give a character literal the char8_t, char16_t and char32_t types, which SWIG has no type for.
auto char_utf8 = u8'c';
auto char_char16 = u'c';
auto char_char32 = U'c';
auto char_paren = (u'c');
decltype(auto) dauto_char32 = U'c';
const auto& cref_char16 = u'c';

// No prefix gives char and an L prefix gives wchar_t, both of which are wrapped.
auto char_plain = 'c';
auto char_wide = L'c';
