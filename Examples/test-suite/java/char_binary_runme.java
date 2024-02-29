import char_binary.*;

public class char_binary_runme {

  static {
    try {
	System.loadLibrary("char_binary");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Test t = new Test();

    String hile = "hile";
    if (t.strlen(hile) != 4)
      throw new RuntimeException("bad multi-arg typemap");

    if (t.ustrlen(hile) != 4)
      throw new RuntimeException("bad multi-arg typemap");

    String hil0 = "hil\0";
    if (t.strlen(hil0) != 4)
      throw new RuntimeException("bad multi-arg typemap");

    if (t.ustrlen(hil0) != 4)
      throw new RuntimeException("bad multi-arg typemap");

    // creating a raw char*
    SWIGTYPE_p_char pc = char_binary.new_pchar(5);
    char_binary.pchar_setitem(pc, 0, 'h');
    char_binary.pchar_setitem(pc, 1, 'o');
    char_binary.pchar_setitem(pc, 2, 'l');
    char_binary.pchar_setitem(pc, 3, 'a');
    char_binary.pchar_setitem(pc, 4, '\0');

    /* FIXME: incompatible types: SWIGTYPE_p_char cannot be converted to String
    if (t.strlen(pc) != 4)
        throw new RuntimeException("bad multi-arg typemap");
    if (t.ustrlen(pc) != 4)
        throw new RuntimeException("bad multi-arg typemap");
    */

    /* FIXME: pc cannot be converted to String
    char_binary.setVar_pchar(pc);
    */
    char_binary.setVar_pchar("hola");
    if (!char_binary.getVar_pchar().equals("hola"))
        throw new RuntimeException("bad pointer case");

    /* FIXME: pc cannot be converted to String
    char_binary.setVar_namet(pc);
    */
    char_binary.setVar_namet("hola");
    if (!char_binary.getVar_namet().equals("hola"))
        throw new RuntimeException("bad pointer case");

    char_binary.delete_pchar(pc);
  }
}
