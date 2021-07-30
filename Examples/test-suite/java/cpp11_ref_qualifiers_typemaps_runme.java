import cpp11_ref_qualifiers_typemaps.*;

public class cpp11_ref_qualifiers_typemaps_runme {
  static {
    try {
      System.loadLibrary("cpp11_ref_qualifiers_typemaps");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
    {
      TypemapsNamedParms tm = new TypemapsNamedParms();
      if (tm.fff(cpp11_ref_qualifiers_typemaps.FF1_MFP) != 2)
        throw new RuntimeException("failed");
      if (tm.ccc(cpp11_ref_qualifiers_typemaps.CC4_MFP) != 5)
        throw new RuntimeException("failed");
      if (tm.ggg(cpp11_ref_qualifiers_typemaps.GG7_MFP) != 8)
        throw new RuntimeException("failed");
      if (tm.hhh(cpp11_ref_qualifiers_typemaps.HH10_MFP) != 11)
        throw new RuntimeException("failed");
    }
    {
      TypemapsUnnamedParms tm = new TypemapsUnnamedParms();
      if (tm.fff(cpp11_ref_qualifiers_typemaps.FF1_MFP) != 3)
        throw new RuntimeException("failed");
      if (tm.ccc(cpp11_ref_qualifiers_typemaps.CC4_MFP) != 6)
        throw new RuntimeException("failed");
      if (tm.ggg(cpp11_ref_qualifiers_typemaps.GG7_MFP) != 9)
        throw new RuntimeException("failed");
      if (tm.hhh(cpp11_ref_qualifiers_typemaps.HH10_MFP) != 12)
        throw new RuntimeException("failed");
    }
  }
}

