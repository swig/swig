%module cpp20_spaceship_operator

// Tests are designed so that code compiles with C++98 compilers

%{
#if __cplusplus >= 202002L
#define CPP20 1
#endif
%}

#ifdef CPP20

#define ALIEN (4 <=> 2)

#else

#define ALIEN (-1)

#endif
