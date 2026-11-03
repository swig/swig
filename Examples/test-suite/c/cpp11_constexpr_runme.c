#include "cpp11_constexpr/cpp11_constexpr_wrap.h"
#include <assert.h>
#include <string.h>

int main(int argc, const char *argv[]) {
  // Static constexpr member pointers are passed to a function taking their type
  assert(cpp11_constexpr_takeNonConstPtr(cpp11_constexpr_MemberPointerConstants_NonConstPtr_get()) == 1);
  assert(cpp11_constexpr_takeConstPtr(cpp11_constexpr_MemberPointerConstants_ConstPtr_get()) == 2);
  assert(cpp11_constexpr_takeVolatilePtr(cpp11_constexpr_MemberPointerConstants_VolatilePtr_get()) == 3);
  assert(cpp11_constexpr_takeConstRefPtr(cpp11_constexpr_MemberPointerConstants_ConstRefPtr_get()) == 4);
  assert(cpp11_constexpr_takeConstNoexceptPtr(cpp11_constexpr_MemberPointerConstants_ConstNoexceptPtr_get()) == 5);
  assert(strcmp(cpp11_constexpr_takeConstStringPtr(cpp11_constexpr_MemberPointerConstants_ConstStringPtr_get()), "six") == 0);
  assert(cpp11_constexpr_takeConstDataPtr(cpp11_constexpr_MemberPointerConstants_ConstDataPtr_get()) == 7);
  assert(cpp11_constexpr_takeTypedefPtr(cpp11_constexpr_MemberPointerConstants_TypedefPtr_get()) == 2);
  assert(cpp11_constexpr_takeConstPtr(cpp11_constexpr_MemberPointerConstants_TypedefPtr_get()) == 2);
  return 0;
}
