%module struct_redundant_typedef

%inline %{

typedef struct Foo Foo;

struct Foo {
   int x;
};

int extract(Foo* foo) { return foo->x; }

%}
