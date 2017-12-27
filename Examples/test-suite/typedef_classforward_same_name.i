%module typedef_classforward_same_name

%inline %{
typedef struct Foo Foo;
struct Foo {
   int x;
};
int extract(Foo* foo) { return foo->x; }
%}