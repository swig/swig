/* File : example.cxx */

#include "example.h"

unsigned Foo::count = 0;

Foo::Foo()
{
  ++count;
}

Foo::~Foo()
{
  --count;
}

unsigned Foo::get_count()
{
  return count;
};