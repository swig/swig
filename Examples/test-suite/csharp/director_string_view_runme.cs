using System;
using director_string_viewNamespace;

public class runme
{
  static void Main()
  {
    runme r = new runme();
    r.run();
  }

  void run()
  {
    String s;

    director_string_view_A c = new director_string_view_A("hi");
    for (int i=0; i<3; i++) {
      s = c.call_get(i);
      Object ii = i;
      if (s != ii.ToString()) throw new Exception("director_string_view_A.get(" + i + ") failed. Got:" + s);
    }

    director_string_view_B b = new director_string_view_B("hello");

    s = b.call_get_first();
    if (s != "director_string_view_B.get_first") throw new Exception("call_get_first() failed");

    s = b.call_get(0);
    if (s != "director_string_view_B.get: hello") throw new Exception("get(0) failed");
  }
}

class director_string_view_B : A {
    public director_string_view_B(String first) : base(first) {
    }
    public override String get_first() {
      return "director_string_view_B.get_first";
    }

    public override String get(int n) {
      return "director_string_view_B.get: " + base.get(n);
    }
}

class director_string_view_A : A {
    public director_string_view_A(String first) : base(first) {
    }
    public override String get(int n) {
      Object nn = n;
      return nn.ToString();
    }
}
