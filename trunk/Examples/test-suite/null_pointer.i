%module null_pointer

%inline {
  struct A {};
  
  bool func(A* a) {
    return !a;
  }
}

