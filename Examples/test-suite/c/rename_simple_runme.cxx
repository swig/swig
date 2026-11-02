#include "rename_simple/rename_simple_wrap.h"
#include <assert.h>

using namespace rename_simple;

int main(int argc, const char *argv[]) {
  NewStruct s;
  assert(s.NewInstanceVariable() == 111);
  assert(s.NewInstanceMethod() == 222);
  assert(NewStruct::NewStaticMethod() == 333);
  assert(NewStruct::NewStaticVariable() == 444);
  assert(NewFunction() == 555);
  assert(NewGlobalVariable() == 666);

  s.NewInstanceVariable(1111);
  NewStruct::NewStaticVariable(4444);
  NewGlobalVariable(6666);

  assert(s.NewInstanceVariable() == 1111);
  assert(NewStruct::NewStaticVariable() == 4444);
  assert(NewGlobalVariable() == 6666);
  return 0;
}
