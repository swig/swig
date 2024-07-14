using System;
using char_binaryNamespace;

public class char_binary_runme {

  public static void Main() {
    Test t = new Test();
    string hile = "hile";
    string hil0 = "hil\0";
    if (t.strlen(hile) != 4)
      throw new Exception("bad multi-arg typemap");

    if (t.strlen(hil0) != 4)
      throw new Exception("bad multi-arg typemap");

    if (t.ustrlen(hile) != 4)
      throw new Exception("bad multi-arg typemap");

    if (t.ustrlen(hil0) != 4)
      throw new Exception("bad multi-arg typemap");

    SWIGTYPE_p_char pc = char_binary.new_pchar(5);
    char_binary.pchar_setitem(pc, 0, 'h');
    char_binary.pchar_setitem(pc, 1, 'o');
    char_binary.pchar_setitem(pc, 2, 'l');
    char_binary.pchar_setitem(pc, 3, 'a');
    char_binary.pchar_setitem(pc, 4, '\0');

    /* FIXME: pc is NOT a string
    if (t.strlen(pc) != 4)
      throw new Exception("bad multi-arg typemap");
    if (t.ustrlen(pc) != 4)
      throw new Exception("bad multi-arg typemap");
    */

    /* FIXME: pc is NOT a string
    char_binary.var_pchar = pc;
    */
    char_binary.var_pchar = "hola";
    if (char_binary.var_pchar != "hola")
      throw new Exception("bad pointer case");

    /* FIXME: pc is NOT a string
    char_binary.var_namet = pc;
    */
    char_binary.var_namet = "hola";
    if (char_binary.var_namet != "hola")
        throw new Exception("bad pointer case");

    char_binary.delete_pchar(pc);
  }
}
