%module(directors="1") director_char_array

%feature("director") CharArrayDirector;

%{
// The first array is full, so has no NUL terminator. It must not be read past its end into the second
struct FullCharArray {
  char full[4];
  char after[4];
};
static FullCharArray full_char_array = {{'a', 'b', 'c', 'd'}, {'X', 'Y', 'Z', 0}};
static FullCharArray short_char_array = {{'a', 'b', 0, 0}, {'X', 'Y', 'Z', 0}};
%}

%inline %{
class CharArrayDirector {
public:
  virtual ~CharArrayDirector() {}
  virtual int take_array(char s[4]) { return -1; }
  virtual int take_const_array(const char s[4]) { return -1; }
  virtual int take_array_ref(char (&s)[4]) { return -1; }
  virtual int take_const_array_ref(const char (&s)[4]) { return -1; }
  // NULL from C++ is passed on as for a NULL char *
  virtual int is_null_array(char s[4]) { return -1; }

  int call_take_array() { return take_array(full_char_array.full); }
  int call_take_const_array() { return take_const_array(full_char_array.full); }
  int call_take_array_ref() { return take_array_ref(full_char_array.full); }
  int call_take_const_array_ref() { return take_const_array_ref(full_char_array.full); }
  int call_take_array_short() { return take_array(short_char_array.full); }
  int call_take_array_ref_short() { return take_array_ref(short_char_array.full); }
  int call_is_null_array() { return is_null_array(0); }
};
%}
