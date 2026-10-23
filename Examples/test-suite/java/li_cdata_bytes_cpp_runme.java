import li_cdata_bytes_cpp.*;

public class li_cdata_bytes_cpp_runme {

  static {
    try {
        System.loadLibrary("li_cdata_bytes_cpp");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) throws Throwable
  {
    SWIGTYPE_p_void m = li_cdata_bytes_cpp.predefStr();
    byte[] s = li_cdata_bytes_cpp.cdata(m, 0x200);
    for (int i = 0; i < 0x100; i++) {
      int val = Byte.toUnsignedInt(s[i]);
      if (val != i)
        throw new RuntimeException("Wrong value " + val + " at index " + i);
      val = Byte.toUnsignedInt(s[i + 0x100]);
      if (val != i)
        throw new RuntimeException("Wrong value " + val + " at index " + (i + 0x100));
    }
    for (int i = 0; i < 0x100; i++) {
        byte v = (byte)(0x100 - 1 - i);
        s[i] = v;
        s[i + 0x100] = v;
    }
    SWIGTYPE_p_void m2 = li_cdata_bytes_cpp.malloc(0x200);
    li_cdata_bytes_cpp.memmove(m2, s);
    if (li_cdata_bytes_cpp.verifyBytes(m2) != 0)
        throw new RuntimeException("verifyBytes fails");
    li_cdata_bytes_cpp.free(m2);
  }
}
