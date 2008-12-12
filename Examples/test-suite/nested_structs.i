%module nested_structs

// bug #491476
%inline %{
struct {
struct {
int a;
} a, b;
} a;

%}

// bug #909387
%inline %{
struct foo {
  struct happy; // no warning
  struct sad { int x; }; // warning
  happy *good(); // produces good code
  sad *bad(); // produces bad code
};
%}

