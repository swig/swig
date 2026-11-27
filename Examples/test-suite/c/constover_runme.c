#include "constover/constover_wrap.h"
#include <assert.h>
#include <string.h>

int main(int argc, const char *argv[]) {
  char x[] = "test";
  constover_Foo *f;
  constover_FooVolatile *fv;
  constover_FooVolatileOverloaded *fvo;
  constover_FooQualifiersOverloaded *fqo;

  assert(strcmp(constover_test(x), "test") == 0);
  assert(strcmp(constover_test_pconst(x), "test_pconst") == 0);

  f = constover_Foo_new();
  assert(strcmp(constover_Foo_test(f, x), "test") == 0);
  assert(strcmp(constover_Foo_test_pconst(f, x), "test_pconst") == 0);
  assert(strcmp(constover_Foo_test_constm(f, x), "test_constmethod") == 0);
  assert(strcmp(constover_Foo_test_pconstm(f, x), "test_pconstmethod") == 0);
  constover_Foo_delete(f);

  fv = constover_FooVolatile_new();
  assert(strcmp(constover_FooVolatile_test(fv, x), "test_volatilemethod") == 0);
  assert(strcmp(constover_FooVolatile_test_cvm(fv, x), "test_cvmethod") == 0);
  constover_FooVolatile_delete(fv);

  fvo = constover_FooVolatileOverloaded_new();
  assert(strcmp(constover_FooVolatileOverloaded_overloaded_pc(fvo, x), "overloaded_volatilemethod") == 0);
  assert(strcmp(constover_FooVolatileOverloaded_overloaded_const_pc(fvo, x), "overloaded_cvmethod") == 0);
  constover_FooVolatileOverloaded_delete(fvo);

  fqo = constover_FooQualifiersOverloaded_new();
  assert(strcmp(constover_FooQualifiersOverloaded_v_pc(fqo, x), "v_method") == 0);
  assert(strcmp(constover_FooQualifiersOverloaded_v_volatile_pc(fqo, x), "v_volatilemethod") == 0);
  assert(strcmp(constover_FooQualifiersOverloaded_cv_pc(fqo, x), "cv_method") == 0);
  assert(strcmp(constover_FooQualifiersOverloaded_cv_const_volatile_pc(fqo, x), "cv_cvmethod") == 0);
  assert(strcmp(constover_FooQualifiersOverloaded_vc_volatile_pc(fqo, x), "vc_volatilemethod") == 0);
  assert(strcmp(constover_FooQualifiersOverloaded_vc_const_pc(fqo, x), "vc_constmethod") == 0);
  constover_FooQualifiersOverloaded_delete(fqo);
  return 0;
}
