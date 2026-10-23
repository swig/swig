%module xxx

template <typename T>
struct Box {
  T value;
  Box(T v) : value(v) {}
};

// CTAD deduced from the constructor - SWIG cannot determine the type, so warns and skips it.
Box bx{42};
