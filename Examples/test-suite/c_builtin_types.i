%module c_builtin_types

// The builtin types other than int are declared in the header file as int is, with a global variable not wrapped with accessor functions without -namespace
%inline %{
unsigned int unsigned_count = 1;
long long long_long_count = 2;

struct BuiltinArrays {
  unsigned int uints[2];
  long long long_longs[2];
  static unsigned short ushorts[2];
};
unsigned short BuiltinArrays::ushorts[2] = {3, 4};

unsigned int unsigned_pointer_value(unsigned int ***p) {
  return ***p;
}
%}
