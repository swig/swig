#include <assert.h>
#include <string.h>

#include "volatile_qualifiers/volatile_qualifiers_wrap.h"

int main(void) {
  int i = 5;
  const int ci = 6;
  char s[] = "four";
  const char *cs = "three";
  volatile_qualifiers_Item *item = volatile_qualifiers_Item_new(7);
  volatile_qualifiers_Members *m = volatile_qualifiers_Members_new();

  assert(volatile_qualifiers_int_ptr(&i) == 5);
  assert(volatile_qualifiers_const_int_ptr(&ci) == 6);
  assert(volatile_qualifiers_volatile_int_ptr(&i) == 5);
  assert(volatile_qualifiers_const_volatile_int_ptr(&ci) == 6);
  assert(volatile_qualifiers_int_volatile_ptr(&i) == 5);
  assert(volatile_qualifiers_volatile_int_value(i) == 5);
  assert(volatile_qualifiers_const_volatile_int_value(ci) == 6);
  assert(volatile_qualifiers_volatile_int_ref(&i) == 5);
  assert(volatile_qualifiers_const_volatile_int_ref(ci) == 6);

  assert(volatile_qualifiers_char_ptr(s) == 4);
  assert(volatile_qualifiers_const_char_ptr("three") == 5);
  assert(volatile_qualifiers_volatile_char_ptr(s) == 4);
  assert(volatile_qualifiers_const_volatile_char_ptr(cs) == 5);
  assert(volatile_qualifiers_char_volatile_ptr(s) == 4);

  assert(volatile_qualifiers_item_ptr(item) == 7);
  assert(volatile_qualifiers_const_item_ptr(item) == 7);
  assert(volatile_qualifiers_volatile_item_ptr(item) == 7);
  assert(volatile_qualifiers_const_volatile_item_ptr(item) == 7);
  assert(volatile_qualifiers_item_volatile_ptr(item) == 7);
  assert(volatile_qualifiers_volatile_item_ref(item) == 7);
  assert(volatile_qualifiers_const_volatile_item_ref(item) == 7);
  assert(volatile_qualifiers_volatile_item_value(item) == 7);
  assert(volatile_qualifiers_const_volatile_item_value(item) == 7);

  assert(*volatile_qualifiers_volatile_int_ptr_return() == 50);
  assert(strcmp(volatile_qualifiers_const_volatile_char_ptr_return(), "return") == 0);
  assert(volatile_qualifiers_Item_x_get(volatile_qualifiers_volatile_item_ptr_return(item)) == 7);
  assert(volatile_qualifiers_Item_x_get(volatile_qualifiers_const_volatile_item_ref_return(item)) == 7);

  volatile_qualifiers_global_volatile_int_set(3);
  assert(volatile_qualifiers_global_volatile_int_get() == 3);
  assert(volatile_qualifiers_global_const_volatile_int_get() == 2);
  volatile_qualifiers_global_char_volatile_ptr_set(s);
  assert(strcmp(volatile_qualifiers_global_char_volatile_ptr_get(), "four") == 0);
  volatile_qualifiers_global_item_volatile_ptr_set(item);
  assert(volatile_qualifiers_Item_x_get(volatile_qualifiers_global_item_volatile_ptr_get()) == 7);
  volatile_qualifiers_global_volatile_int_ptr_set(&i);
  assert(*volatile_qualifiers_global_volatile_int_ptr_get() == 5);
  volatile_qualifiers_global_volatile_item_ptr_set(item);
  assert(volatile_qualifiers_Item_x_get(volatile_qualifiers_global_volatile_item_ptr_get()) == 7);
  assert(strcmp(volatile_qualifiers_global_const_volatile_char_const_ptr_get(), "global") == 0);

  assert(volatile_qualifiers_Members_volatile_int_get(m) == 10);
  volatile_qualifiers_Members_volatile_int_set(m, 11);
  assert(volatile_qualifiers_Members_volatile_int_get(m) == 11);
  assert(volatile_qualifiers_Members_const_volatile_int_get(m) == 20);
  volatile_qualifiers_Members_char_volatile_ptr_set(m, s);
  assert(strcmp(volatile_qualifiers_Members_char_volatile_ptr_get(m), "four") == 0);
  volatile_qualifiers_Members_volatile_item_ptr_set(m, item);
  assert(volatile_qualifiers_Item_x_get(volatile_qualifiers_Members_volatile_item_ptr_get(m)) == 7);
  volatile_qualifiers_Members_item_volatile_ptr_set(m, item);
  assert(volatile_qualifiers_Item_x_get(volatile_qualifiers_Members_item_volatile_ptr_get(m)) == 7);

  assert(volatile_qualifiers_Members_static_volatile_int_get() == 30);
  volatile_qualifiers_Members_static_volatile_int_set(31);
  assert(volatile_qualifiers_Members_static_volatile_int_get() == 31);
  assert(volatile_qualifiers_Members_static_const_volatile_int_get() == 40);
  volatile_qualifiers_Members_static_char_volatile_ptr_set(s);
  assert(strcmp(volatile_qualifiers_Members_static_char_volatile_ptr_get(), "four") == 0);
  volatile_qualifiers_Members_static_item_volatile_ptr_set(item);
  assert(volatile_qualifiers_Item_x_get(volatile_qualifiers_Members_static_item_volatile_ptr_get()) == 7);

  volatile_qualifiers_Members_delete(m);
  volatile_qualifiers_Item_delete(item);
  return 0;
}
