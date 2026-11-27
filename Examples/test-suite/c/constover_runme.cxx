#include "constover/constover_wrap.h"
#include <assert.h>
#include <string.h>

using namespace constover;

int main(int argc, const char *argv[]) {
  char x[] = "test";
  const char *cx = x;

  assert(strcmp(test(x), "test") == 0);
  assert(strcmp(test_pconst(cx), "test_pconst") == 0);

  Foo f;
  const Foo &cf = f;
  assert(strcmp(f.test(x), "test") == 0);
  assert(strcmp(f.test_pconst(cx), "test_pconst") == 0);
  assert(strcmp(cf.test_constm(x), "test_constmethod") == 0);
  assert(strcmp(cf.test_pconstm(cx), "test_pconstmethod") == 0);

  FooVolatile fv;
  const FooVolatile &cfv = fv;
  assert(strcmp(fv.test(x), "test_volatilemethod") == 0);
  assert(strcmp(cfv.test_cvm(x), "test_cvmethod") == 0);
  return 0;
}
