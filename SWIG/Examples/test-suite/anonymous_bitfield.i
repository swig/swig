%module anonymous_bitfield 

%inline %{

struct Foo {
   int x : 4;
   int y : 4;
   int   : 2;
   unsigned int f : 1;
   unsigned int : 5;
   int z : 15;
};

%}

