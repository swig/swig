module director_string_runme;

import Integer = tango.text.convert.Integer;
import director_string.A;

void main() {
  char[] s;

  auto c = new director_string_A("hi");
  for (int i=0; i<3; ++i) {
    s = c.call_get(i);
    if (s != Integer.toString(i)) throw new Exception("director_string_A.get(" ~ Integer.toString(i) ~ ") failed. Got:" ~ s);
  }

  auto b = new director_string_B("hello");

  s = b.call_get_first();
  if (s != "director_string_B.get_first") throw new Exception("call_get_first() failed");

  s = b.call_get(0);
  if (s != "director_string_B.get: hello") throw new Exception("get(0) failed");
}

class director_string_B : A {
public:
  this(char[] first) {
    super(first);
  }
  override char[] get_first() {
    return "director_string_B.get_first";
  }

  override char[] get(int n) {
    return "director_string_B.get: " ~ super.get(n);
  }
}

class director_string_A : A {
public:
  this(char[] first) {
    super(first);
  }
  override char[] get(int n) {
    return Integer.toString(n);
  }
}
