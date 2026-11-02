#include "cpp17_map_no_default_ctor/cpp17_map_no_default_ctor_wrap.h"
#include <assert.h>

int main() {
  cpp17_map_no_default_ctor_NoDefaultConstructorStruct *one = cpp17_map_no_default_ctor_NoDefaultConstructorStruct_new(1);
  cpp17_map_no_default_ctor_NoDefaultConstructorStruct *two = cpp17_map_no_default_ctor_NoDefaultConstructorStruct_new(2);
  cpp17_map_no_default_ctor_NoDefaultConstructorStructMap *map = cpp17_map_no_default_ctor_NoDefaultConstructorStructMap_new();

  cpp17_map_no_default_ctor_NoDefaultConstructorStructMap_set(map, 10, one);
  assert(cpp17_map_no_default_ctor_NoDefaultConstructorStructMap_size(map) == 1);
  assert(cpp17_map_no_default_ctor_NoDefaultConstructorStruct_value_get(cpp17_map_no_default_ctor_NoDefaultConstructorStructMap_get(map, 10)) == 1);

  cpp17_map_no_default_ctor_NoDefaultConstructorStructMap_set(map, 10, two);
  assert(cpp17_map_no_default_ctor_NoDefaultConstructorStructMap_size(map) == 1);
  assert(cpp17_map_no_default_ctor_NoDefaultConstructorStruct_value_get(cpp17_map_no_default_ctor_NoDefaultConstructorStructMap_get(map, 10)) == 2);

  cpp17_map_no_default_ctor_NoDefaultConstructorStructMap_delete(map);
  cpp17_map_no_default_ctor_NoDefaultConstructorStruct_delete(two);
  cpp17_map_no_default_ctor_NoDefaultConstructorStruct_delete(one);
  return 0;
}
