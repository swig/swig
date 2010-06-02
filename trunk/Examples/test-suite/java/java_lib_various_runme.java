
// Test case to check typemaps in various.i

import java_lib_various.*;

public class java_lib_various_runme {

  static {
    try {
	System.loadLibrary("java_lib_various");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    // STRING_ARRAY typemap parameter
    String animals[] = {"Cat","Dog","Cow","Goat"};
    if (java_lib_various.check_animals(animals) != 1)
      throw new RuntimeException("check_animals failed");

    // STRING_ARRAY typemap return value
    String expected[] = { "Dave", "Mike", "Susan", "John", "Michelle" };
    String got[] = java_lib_various.get_names();
    for (int i=0; i<got.length; i++)
      if ( !got[i].equals(expected[i]) )
        throw new RuntimeException("Name failed " + i + " " + got[i] + "|" + expected[i]);

    // STRING_ARRAY variable getter
    String langscheck[] = { "Hungarian", "Afrikaans", "Norwegian" };
    String langs[] = java_lib_various.getLanguages();
    for (int i=0; i<langs.length; i++)
      if ( !langs[i].equals(langscheck[i]) )
        throw new RuntimeException("Languages read failed " + i + " " + langs[i] + "|" + langscheck[i]);

    // STRING_ARRAY variable setter
    String newLangs[] = { "French", "Italian", "Spanish" };
    java_lib_various.setLanguages(newLangs);

    // STRING_ARRAY variable getter
    langs = java_lib_various.getLanguages();
    for (int i=0; i<langs.length; i++)
      if ( !langs[i].equals(newLangs[i]) )
        throw new RuntimeException("Languages verify failed " + i + " " + langs[i] + "|" + newLangs[i]);

    // STRING_RET test
    {
      String stringOutArray[] = { "" };
      java_lib_various.char_ptr_ptr_out(stringOutArray);
      if (!stringOutArray[0].equals("returned string"))
        throw new RuntimeException("Test failed: expected: returned string. got: " + stringOutArray[0]);
    }

    // STRING_RET null array test. Check that exception is thrown.
    try {
      String stringOutArray[] = null;
      java_lib_various.char_ptr_ptr_out(stringOutArray);
      throw new RuntimeException("Test failed: null array");
    } catch (NullPointerException e) {
    }

    // STRING_RET empty array test. Check that exception is thrown.
    try {
      String stringOutArray[] = {};
      java_lib_various.char_ptr_ptr_out(stringOutArray);
      throw new RuntimeException("Test failed: empty array");
    } catch (IndexOutOfBoundsException e) {
    }

    // BYTE typemap check
    byte b[] = new byte[20];
    java_lib_various.charout(b);
    String byjovestring = new String("by jove");
    byte byjove[] = byjovestring.getBytes();
    for (int i=0; i<byjovestring.length(); i++) {
      if (byjove[i] != b[i])
        throw new RuntimeException("By jove, it failed: [" + new String(b) + "]");
    }
  }

}
