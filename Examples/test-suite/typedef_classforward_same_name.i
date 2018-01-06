%module typedef_classforward_same_name

%inline %{
typedef struct Foo Foo;
struct Foo {
   int x;
};
int extractFoo(Foo* foo) { return foo->x; }

struct Boo {
   int x;
};
typedef struct Boo Boo;
int extractBoo(Boo* boo) { return boo->x; }
%}
