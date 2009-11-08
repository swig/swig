%module nested_structs

// bug #491476
%inline %{
struct {
struct {
int a;
} a, b;
} a;

%}

