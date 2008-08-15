

/** This is a block describing enum
 */

enum color { RED, BLUE, GREEN };

/*! This is describing class foo
 */

class Foo {
 public:
  Foo() { }
  enum speed { IMPULSE=10, WARP=20, LUDICROUS=30 };
  void enum_test(speed s);
};

/*! This is describing enum test
//! \param c the color c
//! \param s the speed
 */

void enum_test(color c, Foo::speed s);
