
import doxygen_basic_notranslate.*;
import java.util.HashMap;

public class doxygen_basic_notranslate_runme {
  static {
    try {
      System.loadLibrary("doxygen_basic_notranslate");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }
  
  public static void main(String argv[]) 
  {
    CommentParser.parse("doxygen_basic_notranslate");

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    wantedComments.put("doxygen_basic_notranslate.doxygen_basic_notranslate.function3(int)",
    		" \n" +
    		"  A test for overloaded functions\n" +
    		"  This is function \\b one\n" +
    		"  \n" +
    		"");
    wantedComments.put("doxygen_basic_notranslate.doxygen_basic_notranslate.function4()",
    		" \n" +
    		"  A test of some mixed tag usage\n" +
    		"  \\if CONDITION\n" +
    		"  This \\a code fragment shows us something \\.\n" +
    		"  \\par Minuses:\n" +
    		"  \\arg it's senseless\n" +
    		"  \\arg it's stupid\n" +
    		"  \\arg it's null\n" +
    		" \n" +
    		"  \\warning This may not work as expected\n" +
    		" \n" +
    		"  \\code\n" +
    		"  int main() { while(true); }\n" +
    		"  \\endcode\n" +
    		"  \\endif\n" +
    		"  \n" +
    		"");
    wantedComments.put("doxygen_basic_notranslate.doxygen_basic_notranslate.function()",
    		" \n" +
    		"  \\brief\n" +
    		"  Brief description.\n" +
    		"  \n" +
    		"  The comment text\n" +
    		"  \\author Some author\n" +
    		"  \\return Some number\n" +
    		"  \\sa function2\n" +
    		"  \n" +
    		"");
    wantedComments.put("doxygen_basic_notranslate.doxygen_basic_notranslate.function5(int)",
    		"  This is a post comment. ");
    wantedComments.put("doxygen_basic_notranslate.doxygen_basic_notranslate.function7(doxygen_basic_notranslate.SWIGTYPE_p_p_p_Shape)",
    		" \n" +
    		"  Test for a parameter with difficult type\n" +
    		"  (mostly for python)\n" +
    		"  @param a Very strange param\n" +
    		"  \n" +
    		"");
    wantedComments.put("doxygen_basic_notranslate.doxygen_basic_notranslate.function3(int, int)",
    		" \n" +
    		"  A test for overloaded functions\n" +
    		"  This is function \\b two\n" +
    		"  \n" +
    		"");
    wantedComments.put("doxygen_basic_notranslate.doxygen_basic_notranslate.function6(int)",
    		" \n" +
    		"  Test for default args\n" +
    		"  @param a Some parameter, default is 42\n" +
    		"  \n" +
    		"");
    wantedComments.put("doxygen_basic_notranslate.doxygen_basic_notranslate.function6()",
    		" \n" +
    		"  Test for default args\n" +
    		"  @param a Some parameter, default is 42\n" +
    		"  \n" +
    		"");
    wantedComments.put("doxygen_basic_notranslate.doxygen_basic_notranslate.function1()",
    		"  Single line comment ");
    wantedComments.put("doxygen_basic_notranslate.doxygen_basic_notranslate.function2()",
    		" \n" +
    		"  A test of a very very very very very very very very very very very very very very very very\n" +
    		"  very very very very very long comment string.\n" +
    		"  \n" +
    		"");
    
    // and ask the parser to check comments for us
    System.exit(CommentParser.check(wantedComments));
  }
}
