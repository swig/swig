/* File : example.h */

// Constants
#define ICONST 42
#define FCONST 2.1828
#define SCONST "Hello World"

#define EXPR ICONST + 3 * FCONST

// Enums
enum color { RED, BLUE, GREEN };

class Foo {
 public:
  Foo() { }
  enum speed { IMPULSE, WARP, LUDICROUS };
  void enum_test(speed s);
};

void enum_test(enum color c, Foo::speed s);
