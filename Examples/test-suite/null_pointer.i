%module null_pointer

%inline {
  struct A {};
  
  bool funk(A* a) {
    return !a;
  }

  A* getnull() {
    return 0;
  }
}

