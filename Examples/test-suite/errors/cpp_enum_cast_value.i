%module xxx

// An enumerator initialised with a named cast takes the type cast to, so a cast to a non-integral type is
// rejected the same way any other non-integral enumerator value is.

enum Good {
  GA = static_cast<char>(65),
  GB = static_cast<bool>(1),
  GC = static_cast<long>(2)
};

enum Bad {
  BA = static_cast<double>(1)
};
