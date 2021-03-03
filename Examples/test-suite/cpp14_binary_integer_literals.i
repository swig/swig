%module cpp14_binary_integer_literals

// Tests are designed so that code compiles with C++98 compilers

%{
#if __cplusplus >= 201402L
#define CPP14 1
#endif
%}

int b1 = 0b1;
int b2 = 0b10;
long b3 = 0b11l;
unsigned long b4 = 0b100ul;
unsigned long b5 = 0B101UL;

%{
#if defined(CPP14)
int b1 = 0b1;
int b2 = 0b10;
long b3 = 0b11l;
unsigned long b4 = 0b100ul;
unsigned long b5 = 0B101UL;
#else
int b1 = 1;
int b2 = 2;
long b3 = 3;
unsigned long b4 = 4;
unsigned long b5 = 5;
#endif
%}
