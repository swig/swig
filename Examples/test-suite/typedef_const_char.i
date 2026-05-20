%module typedef_const_char

// Test that typedef'd const char* works correctly (GitHub issue #3290).
// The Go 'in' typemap for char* must handle const char* properly.

%inline %{

typedef const char* MyString;

MyString test_typedef_const_char(MyString s) {
  return s;
}

const char* test_const_char(const char* s) {
  return s;
}

MyString echo_typedef(MyString s1, MyString s2) {
  return s1;
}

%}
