/* Test whether anonymous enums are supported well. */

%module "enums"

%inline %{

typedef enum { 
    CSP_ITERATION_FWD,
    CSP_ITERATION_BWD
} foo1;

typedef enum foo2 {
    ABCDE = 0,
    FGHJI = 1
} foo3;

void
bar1(foo1 x) {}

void
bar2(enum foo2 x) {}

void 
bar3(foo3 x) {}


%}
