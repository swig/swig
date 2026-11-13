%module(directors="1") python_thisown_capsule

// The reference each wrapper holds on the runtime data capsule must stay balanced whatever
// happens to its ownership after creation: thisown, disown(), acquire(), DISOWN typemaps and
// director return values.

%feature("director") Factory;
%warnfilter(SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) Factory::create;

%apply SWIGTYPE *DISOWN { Item *disowned };

%inline %{
struct Item {
  int x;
  Item() : x(1) {}
};
// Raw pointer return: the Python wrapper does not own the object
Item *make_item() { return new Item(); }
// Takes ownership away from the Python wrapper, without deleting the object
Item *pass_through(Item *disowned) { return disowned; }

struct Factory {
  virtual ~Factory() {}
  virtual Item *create() { return new Item(); }
};
// The returned object is owned by C++ (DISOWN in the director return path)
void create_and_delete(Factory *f) { delete f->create(); }
%}
