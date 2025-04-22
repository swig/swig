%module extend_splitting
// Test %extend with code splitting
// This test should work w/o multiple definitions in the linker

%extend Object {
  int get() {
    return $self->v;
  }
}

%inline {
struct Object {
  int v;
  Object(int x);
};
}

%insert("wrapper") {
  Object::Object(int x) : v(x) {}
}
