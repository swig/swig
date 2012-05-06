/* File : example.h */

#include <iostream>

using namespace std;

class Bar
{
 public:
  virtual void bar ()
    {
      cout << "bar" << endl;
    }
};

class Foo
{
 public:
  virtual void foo ()
    {
      cout << "foo" << endl;
    }
};

class Foo_Bar : public Foo, public Bar
{
 public:
  virtual void fooBar ()
    {
      cout << "foobar" << endl;
    }
};
