%module xxx

// An out of line nested class definition written inside the enclosing class. The immediate outer
// class is itself a nested class, so it is unsupported and not wrapped (Warning 325). The enclosing
// scope must still resolve so that the out of line definition is accepted - previously this also
// reported the spurious error "Outer is not defined as a valid scope".

namespace ns {
struct Enclosing {
  struct Outer {
    struct Nested;
  };
  struct Outer::Nested {
    int data;
  };
};
}
