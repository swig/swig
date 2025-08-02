using System;
using char_binary_rev_lenNamespace;

public class char_binary_rev_len_runme {

  public static void Main() {
    Test t = new Test();
    string hile = "hile";
    string hil0 = "hil\0";
    if (t.strlen(hile) != 4)
      throw new Exception("bad multi-arg typemap");

    if (t.strlen(hil0) != 4)
      throw new Exception("bad multi-arg typemap");
  }
}
