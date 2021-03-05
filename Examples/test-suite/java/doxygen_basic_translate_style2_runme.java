
import doxygen_basic_translate_style2.*;
import java.util.HashMap;

public class doxygen_basic_translate_style2_runme {
  static {
    try {
      System.loadLibrary("doxygen_basic_translate_style2");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }
  
  public static void main(String argv[]) 
  {
    CommentParser.parse("doxygen_basic_translate_style2");

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    
    wantedComments.put("doxygen_basic_translate_style2.doxygen_basic_translate_style2.function()",
    		" \n" +
    		" Brief description.\n" +
    		" \n" +
    		" The comment text.\n" +
    		" @author Some author\n" +
    		" @return Some number\n" +
    		" @see function2\n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_basic_translate_style2.doxygen_basic_translate_style2.function2()",
    		" A test of a very very very very very very very very very very very very very very very very \n" +
    		" very very very very very long comment string. \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_basic_translate_style2.doxygen_basic_translate_style2.function4()",
    		" A test of some mixed tag usage \n" +
    		" If: CONDITION {\n" +
    		" This <i>code </i>fragment shows us something . \n" +
    		" <p alt=\"Minuses: \">\n" +
    		" <li>it's senseless \n" +
    		" </li><li>it's stupid \n" +
    		" </li><li>it's null \n" +
    		" \n" +
    		" </li></p>Warning: This may not work as expected \n" +
    		" \n" +
    		" {@code \n" +
    		"int main() { while(true); } \n" +
		"\n" +
		"// Test blank line in code block \n" +
    		" }\n" +
    		" }\n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_basic_translate_style2.doxygen_basic_translate_style2.function3(int)",
    		" A test for overloaded functions \n" +
    		" This is function <b>one </b>\n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_basic_translate_style2.doxygen_basic_translate_style2.function5(int)",
    		" This is a post comment. \n" +
    		"");
    wantedComments.put("doxygen_basic_translate_style2.doxygen_basic_translate_style2.function6(int)",
    		" Test for default args \n" +
    		" @param a Some parameter, default is 42" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_basic_translate_style2.doxygen_basic_translate_style2.function6()",
    		" Test for default args \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_basic_translate_style2.doxygen_basic_translate_style2.function7(doxygen_basic_translate_style2.SWIGTYPE_p_p_p_Shape)",
    		" Test for a parameter with difficult type \n" +
    		" (mostly for python) \n" +
    		" @param a Very strange param \n" +
    		"");
    wantedComments.put("doxygen_basic_translate_style2.doxygen_basic_translate_style2.function3(int, int)",
    		" A test for overloaded functions \n" +
    		" This is function <b>two </b>\n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_basic_translate_style2.doxygen_basic_translate_style2.Atan2(double, double)",
    		" Multiple parameters test.\n" +
    		" \n" +
    		" @param y Vertical coordinate.\n" +
    		" @param x Horizontal coordinate.\n" +
    		" @return Arc tangent of <code>y/x</code>.\n" +
    		"");

    // and ask the parser to check comments for us
    System.exit(CommentParser.check(wantedComments));
  }
}
