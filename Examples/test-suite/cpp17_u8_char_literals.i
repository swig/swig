%module cpp17_u8_char_literals

%inline %{
// UTF-8 character literals will (apparently) have type char8_t in C++20.
char a = u8'a';
char u = u8'u';
char u8 = u8'8';
%}
