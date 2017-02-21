/* File : example.h */

#include <string>

class Foo
{
  static unsigned count;
public:
  Foo();
  ~Foo();
  static unsigned get_count();
};

static Foo* verify_no_memory_leak(const std::string& message, Foo* foo);