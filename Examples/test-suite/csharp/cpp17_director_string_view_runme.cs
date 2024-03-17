using System;
using cpp17_director_string_viewNamespace;

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

    cpp17_director_string_view_A c = new cpp17_director_string_view_A("hi");
    for (int i=0; i<3; i++) {
      s = c.call_get(i);
      Object ii = i;
      if (s != ii.ToString()) throw new Exception("cpp17_director_string_view_A.get(" + i + ") failed. Got:" + s);
    }

    cpp17_director_string_view_B b = new cpp17_director_string_view_B("hello");

    s = b.get_first();
    if (s != "cpp17_director_string_view_B.get_first") throw new Exception("get_first() failed");

    s = b.call_get_first();
    if (s != "cpp17_director_string_view_B.get_first") throw new Exception("call_get_first() failed");

    s = b.call_get(0);
    if (s != "cpp17_director_string_view_B.get: hello") throw new Exception("get(0) failed");
  }
}

class cpp17_director_string_view_B : A {
    public cpp17_director_string_view_B(String first) : base(first) {
    }
    public override String get_first() {
      return "cpp17_director_string_view_B.get_first";
    }

    public override String get(int n) {
      return "cpp17_director_string_view_B.get: " + base.get(n);
    }
}

class cpp17_director_string_view_A : A {
    public cpp17_director_string_view_A(String first) : base(first) {
    }
    public override String get(int n) {
      Object nn = n;
      return nn.ToString();
    }
}
