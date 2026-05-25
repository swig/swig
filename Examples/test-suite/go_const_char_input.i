%module go_const_char_input

// Test that various const char pointer/array types work correctly
// in the Go 'in' typemap (GitHub issue #3290).
//
// The Go 'in' typemap for char* must handle const char* properly,
// whether bare (const char*) or via typedef (typedef const char* T).

%inline %{

typedef const char* MyString;

MyString test_typedef(MyString s) {
  return s;
}

const char* test_const_char(const char* s) {
  return s;
}

const char* test_const_char_array(const char s[]) {
  return s;
}

const char* test_fixed_array(const char s[16]) {
  return s;
}

%}
