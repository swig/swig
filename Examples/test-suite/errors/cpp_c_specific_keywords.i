%module xxx

// Test handling of C keywords which aren't C++ keywords.

struct A {
  // These are C keywords but SWIG should not treat them as keywords in C++
  // so should not emit an error for these uses.  Note that identifiers
  // starting `_` followed by an upper case ASCII letter are reserved and using
  // these as identifiers makes the program ill-formed, so we don't want to try
  // to compile the generated code.
  bool _Bool; // C99.
  int _Complex; // C99

  // Check that SWIG does error for uses of the equivalent C++ keyword, since
  // if it doesn't then our test above doesn't really prove anything.
  bool bool;
};
