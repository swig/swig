%module cpp17_u8_char_literals

// Tests are designed so that code compiles with C++98 compilers

%{
#if __cplusplus >= 201703L
#define CPP17 1
#endif
%}

// UTF-8 character literals are type `char` in C++17 but `char8_t` in C++20,
// but the latter can be assigned to `char`.
char a = u8'a';
char u = u8'u';
char u8 = u8'8';

%{
#if defined(CPP17)
char a = u8'a';
char u = u8'u';
char u8 = u8'8';
#else
char a = 'a';
char u = 'u';
char u8 = '8';
#endif
%}
