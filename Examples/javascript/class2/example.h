/* File : example.h */

#include <stdio.h>
#include <stdlib.h>

class Foo {
public:
  Foo() {
    p = (int*)malloc(1);
    *p = 0xF00;
    printf("Foo::Foo: %p %x\n", p, *p);
  }
  virtual ~Foo() {
    printf("Foo::~Foo: %p %x\n", p, *p);
    *p = 0;
    free(p);
    p = NULL;
  }
  virtual Foo *inc() {
    if(p) {
      (*p)++;
      printf("Foo::inc: %p -> %x\n", p, *p);
    } else {
      printf("Foo::inc: <null>\n");
    }
    return this;
  }
private:  
  int *p;
};
