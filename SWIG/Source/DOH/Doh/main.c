#include "doh.h"

int main() {
  DOH *d1, *d2, *d3;
  DOH *f;
  DOH *l;
  DOH *h;

  printf("starting...\n");
  f = NewFile("foo","w");
  printf("%x\n",f);
  d1 = NewString("Hello");
  d2 = NewString("World");
  Append(d1,d2);
  Printf(d1,"This is a test %d", 42);
  Setattr(d1,"foo",d2);
  Printf(f,"Hello World\n");
  Printf(f,"%s\n",d1);
  l = NewList();
  Append(l,d1);
  Append(l,d2);
  Append(l,f);
  h = NewHash();
  Setattr(h,"foo",d1);
  Setattr(h,"bar",l);
  Printf(f,"%o\n",l);
  Printf(f,"%o\n",h);
  Printf(f,"%o\n", Getattr(h,"bar"));
}
  
