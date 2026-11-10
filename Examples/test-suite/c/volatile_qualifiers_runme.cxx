#include <assert.h>
#include <string.h>

#include "volatile_qualifiers/volatile_qualifiers_wrap.h"

using namespace volatile_qualifiers;

static int x_of(Item *p) {
  int x = p->x();
  delete p;
  return x;
}

int main() {
  int i = 5;
  const int ci = 6;
  char s[] = "four";
  Item item(7);
  const Item &citem = item;
  Members m;

  // The C++ wrappers have these types without volatile
  int (*volatile_int_ptr_function)(int *) = volatile_int_ptr;
  int (*const_volatile_int_ptr_function)(const int *) = const_volatile_int_ptr;
  int (*const_volatile_int_ref_function)(int) = const_volatile_int_ref;
  int (*volatile_char_ptr_function)(char *) = volatile_char_ptr;
  int (*const_volatile_char_ptr_function)(const char *) = const_volatile_char_ptr;
  int (*volatile_item_ptr_function)(Item *) = volatile_item_ptr;
  int (*const_volatile_item_ptr_function)(Item const *) = const_volatile_item_ptr;
  int (*volatile_item_ref_function)(Item &) = volatile_item_ref;
  int (*const_volatile_item_ref_function)(Item const &) = const_volatile_item_ref;
  int (*volatile_item_value_function)(Item const &) = volatile_item_value;
  Item *(*volatile_item_ptr_return_function)(Item *) = volatile_item_ptr_return;

  assert(int_ptr(&i) == 5);
  assert(const_int_ptr(&ci) == 6);
  assert(volatile_int_ptr_function(&i) == 5);
  assert(const_volatile_int_ptr_function(&ci) == 6);
  assert(int_volatile_ptr(&i) == 5);
  assert(volatile_int_value(i) == 5);
  assert(const_volatile_int_value(ci) == 6);
  assert(volatile_int_ref(&i) == 5);
  assert(const_volatile_int_ref_function(ci) == 6);

  assert(char_ptr(s) == 4);
  assert(const_char_ptr("three") == 5);
  assert(volatile_char_ptr_function(s) == 4);
  assert(const_volatile_char_ptr_function("three") == 5);
  assert(char_volatile_ptr(s) == 4);

  assert(item_ptr(&item) == 7);
  assert(const_item_ptr(&citem) == 7);
  assert(volatile_item_ptr_function(&item) == 7);
  assert(const_volatile_item_ptr_function(&citem) == 7);
  assert(item_volatile_ptr(&item) == 7);
  assert(volatile_item_ref_function(item) == 7);
  assert(const_volatile_item_ref_function(citem) == 7);
  assert(volatile_item_value_function(citem) == 7);
  assert(const_volatile_item_value(citem) == 7);

  assert(*volatile_int_ptr_return() == 50);
  assert(strcmp(const_volatile_char_ptr_return(), "return") == 0);
  assert(x_of(volatile_item_ptr_return_function(&item)) == 7);
  assert(const_volatile_item_ref_return(item).x() == 7);

  global_volatile_int(3);
  assert(global_volatile_int() == 3);
  assert(global_const_volatile_int() == 2);
  global_char_volatile_ptr(s);
  assert(strcmp(global_char_volatile_ptr(), "four") == 0);
  global_item_volatile_ptr(&item);
  assert(x_of(global_item_volatile_ptr()) == 7);
  global_volatile_int_ptr(&i);
  assert(*global_volatile_int_ptr() == 5);
  global_volatile_item_ptr(&item);
  assert(x_of(global_volatile_item_ptr()) == 7);
  assert(strcmp(global_const_volatile_char_const_ptr(), "global") == 0);

  assert(m.volatile_int() == 10);
  m.volatile_int(11);
  assert(m.volatile_int() == 11);
  assert(m.const_volatile_int() == 20);
  m.char_volatile_ptr(s);
  assert(strcmp(m.char_volatile_ptr(), "four") == 0);
  m.volatile_item_ptr(&item);
  assert(x_of(m.volatile_item_ptr()) == 7);
  m.item_volatile_ptr(&item);
  assert(x_of(m.item_volatile_ptr()) == 7);

  assert(Members::static_volatile_int() == 30);
  Members::static_volatile_int(31);
  assert(Members::static_volatile_int() == 31);
  assert(Members::static_const_volatile_int() == 40);
  Members::static_char_volatile_ptr(s);
  assert(strcmp(Members::static_char_volatile_ptr(), "four") == 0);
  Members::static_item_volatile_ptr(&item);
  assert(x_of(Members::static_item_volatile_ptr()) == 7);
  return 0;
}
