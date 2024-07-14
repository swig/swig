using System;
using System.Text;
using li_cdataNamespace;

public class li_cdata_runme {

  public static void Main() {
    Encoding utf8 = Encoding.UTF8;
    string s0 = "ABC\0abc";
    byte[] s = utf8.GetBytes(s0);
    SWIGTYPE_p_void m = li_cdata.malloc(256);
    li_cdata.memmove(m, s);
    byte[] ss = li_cdata.cdata(m, 7);
    string ss_string = utf8.GetString(ss);
    if (!ss_string.Equals("ABC\0abc"))
      throw new Exception("failed got: " + ss_string);
  }
}
