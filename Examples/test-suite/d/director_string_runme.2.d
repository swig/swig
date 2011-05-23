module director_string_runme;

import std.conv;
import std.exception;
import director_string.A;

void main() {
  auto c = new director_string_A("hi");
  for (int i=0; i<3; ++i) {
    auto s = c.call_get(i);
    auto expected = to!string(i);
    enforce(s == expected, "director_string_A.get(" ~ expected ~ ") failed. Got:" ~ s);
  }

  auto b = new director_string_B("hello");
  enforce(b.call_get_first() == "director_string_B.get_first", "call_get_first() failed");
  enforce(b.call_get(0) == "director_string_B.get: hello", "get(0) failed");
}

class director_string_B : A {
public:
  this(string first) {
    super(first);
  }
  override string get_first() const {
    return "director_string_B.get_first";
  }

  override string get(int n) const {
    return "director_string_B.get: " ~ super.get(n);
  }
}

class director_string_A : A {
public:
  this(string first) {
    super(first);
  }
  override string get(int n) const {
    return to!string(n);
  }
}
