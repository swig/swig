using System;
using System.Text;
using li_cdata_bytesNamespace;

public class li_cdata_bytes_runme {

  public static void Main() {
    SWIGTYPE_p_void m = li_cdata_bytes.predefStr();
    byte[] s = li_cdata_bytes.cdata(m, 0x200);
    for (uint i = 0; i < 0x100; i++) {
      uint val = Convert.ToUInt32(s[i]);
      if (val != i)
        throw new Exception("Wrong value " + val + " at index " + i);
      val = Convert.ToUInt32(s[i + 0x100]);
      if (val != i)
        throw new Exception("Wrong value " + val + " at index " + (i + 0x100));
    }
    for (uint i = 0; i < 0x100; i++) {
      byte v = (byte)(0x100 - 1 - i);
      s[i] = v;
      s[i + 0x100] = v;
    }
    SWIGTYPE_p_void m2 = li_cdata_bytes.malloc(0x200);
    li_cdata_bytes.memmove(m2, s);
    if (li_cdata_bytes.verifyBytes(m2) != 0)
      throw new Exception("verifyBytes fails");
    li_cdata_bytes.free(m2);
  }
}
