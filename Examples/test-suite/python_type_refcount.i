%module python_type_refcount

// Freeing a wrapper releases the reference it holds on its type when the type is a heap type

%newobject make_item;

%inline %{
struct Item {
  int x;
  static int static_member;
  Item() : x(1) {}
  int get() { return x; }
};
int Item::static_member = 0;
int get_static_member() { return Item::static_member; }
Item *make_item() { return new Item(); }
int *get_int_ptr() { static int an_int = 1; return &an_int; }
typedef int (Item::*ItemMethod)();
ItemMethod get_method() { return &Item::get; }
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}
