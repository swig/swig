/* Test whether anonymous enums are supported well. */

%module "enum"

%inline %{

typedef enum { 
    CSP_ITERATION_FWD,
    CSP_ITERATION_BWD
} CSP_IterDir;

void
CSP_iteration_setup(CSP_IterDir direction);

%}
