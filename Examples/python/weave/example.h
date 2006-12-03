#ifndef _EXAMPLE_H
#define _EXAMPLE_H

class Foo {
 public:
   int x;
};

class Bar {
 public:
   int y;
};

class FooBar : public Foo, public Bar {
 public:
   int z;
};
#endif
