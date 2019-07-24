%module restrict_cplusplus

%{
// Workaround PHP's headers which do:
// #define restrict __restrict__
#ifdef restrict
#undef restrict
#endif
struct Foo {
    int restrict;
};
%}

struct Foo {
    int restrict;
};
