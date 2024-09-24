%module xxx
struct A {
  // C99 _Bool should not be a keyword in C++ so this should not give an error.
  bool _Bool;
};
