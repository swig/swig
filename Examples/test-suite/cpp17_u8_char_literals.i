%module cpp17_u8_char_literals

// UTF-8 character literals are type `char` in C++17 but `char8_t` in C++20,
// but the latter can be assigned to `char`.
%inline %{
char a = u8'a';
char u = u8'u';
char u8 = u8'8';
%}
