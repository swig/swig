public class nspacemove_stl_runme {

  static {
    try {
	System.loadLibrary("nspacemove_stl");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    nspacemove_stlPackage.CPlusPlus.Standard.Ints.VectorInt vi = new nspacemove_stlPackage.CPlusPlus.Standard.Ints.VectorInt();
    nspacemove_stlPackage.CPlusPlus.Standard.Strings.VectorString vs = new nspacemove_stlPackage.CPlusPlus.Standard.Strings.VectorString();
    nspacemove_stlPackage.CPlusPlus.Maps.MapIntInt mii = new nspacemove_stlPackage.CPlusPlus.Maps.MapIntInt();
    nspacemove_stlPackage.CPlusPlus.Maps.MapIntString mis = new nspacemove_stlPackage.CPlusPlus.Maps.MapIntString();

    nspacemove_stlPackage.nspacemove_stl.test_vector_int(vi);
    nspacemove_stlPackage.nspacemove_stl.test_vector_string(vs);
    nspacemove_stlPackage.nspacemove_stl.test_map_int(mii);
    nspacemove_stlPackage.nspacemove_stl.test_map_string(mis);
  }
}
