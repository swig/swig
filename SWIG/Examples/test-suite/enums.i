/* Test whether varios enums in C. */

%module "enums"

/* Suppress warning messages from the Ruby module for all of the following.. */
%warnfilter(801) boo;
%warnfilter(801) hoo;
%warnfilter(801) globalinstance1;
%warnfilter(801) globalinstance2;
%warnfilter(801) globalinstance3;

%inline %{

typedef enum { 
    CSP_ITERATION_FWD,
    CSP_ITERATION_BWD = 11
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

enum sad { boo, hoo = 5 };

/* Unnamed enum instance */
enum { globalinstance1, globalinstance2, globalinstance3 = 30 } GlobalInstance;

/* Anonymous enum */
enum { AnonEnum1, AnonEnum2 = 100 };

%}
