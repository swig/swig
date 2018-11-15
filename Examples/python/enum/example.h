/* File : example.h */

#include <stdio.h>

enum color { RED, BLUE, GREEN };

enum numeric { FIRST=1, SECOND=2, THIRD=3};

class Foo {
 public:
  Foo() { }
  enum speed { IMPULSE, WARP, LUDICROUS };
  void enum_test(speed s);
};

class Bar {
 public:
  Bar(Foo* foo, int number, numeric enumvalue) : n(enumvalue), numericUsed(true) { }
  Bar(Foo* foo, int number, int anothernumber) : n(THIRD), numericUsed(false) { }
  void enum_test();
  void enum_test_cpp() {
    Bar* b = new Bar(new Foo(),1,FIRST);
	printf("The following should say 'FIRST' and 'numeric USED'\n");
	b->enum_test();
	Bar* b2 = new Bar(new Foo(),2,254);
	printf("The following should say 'THIRD'(defaulted) and 'numeric NOT USED'\n");
	b2->enum_test();
	delete(b);
	delete(b2);
  }
  numeric n;
  bool numericUsed;
};

void enum_test(color c, Foo::speed s);
