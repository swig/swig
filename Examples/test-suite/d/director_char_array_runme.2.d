module director_char_array_runme;

import director_char_array.CharArrayDirector;
import std.conv : text;
import std.exception : enforce;

void check(int got, int expected, string what) {
  enforce(got == expected, text(what, " got ", got, " expected ", expected));
}

void main() {
  auto d = new Director();
  check(d.call_take_array(), 4, "take_array");
  check(d.call_take_const_array(), 4, "take_const_array");
  check(d.call_take_array_ref(), 4, "take_array_ref");
  check(d.call_take_const_array_ref(), 4, "take_const_array_ref");
  check(d.call_take_array_short(), 2, "take_array short");
  check(d.call_take_array_ref_short(), 2, "take_array_ref short");
  check(d.call_is_null_array(), 1, "is_null_array");
}

class Director : CharArrayDirector {
public:
  override int take_array(string s) { return cast(int)s.length; }
  override int take_const_array(string s) { return cast(int)s.length; }
  override int take_array_ref(string s) { return cast(int)s.length; }
  override int take_const_array_ref(string s) { return cast(int)s.length; }
  override int is_null_array(string s) { return s is null ? 1 : 0; }
}
