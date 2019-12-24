
import doxygen_translate_links.*;
import java.util.HashMap;

public class doxygen_translate_links_runme {
  static {
    try {
      System.loadLibrary("doxygen_translate_links");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }
  
  public static void main(String argv[]) 
  {
    CommentParser.parse("doxygen_translate_links");

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    
    
    wantedComments.put("doxygen_translate_links.doxygen_translate_links.function()",
    		" \n" +
    		" Testing typenames converting in @ link \n" +
    		" \n" +
    		" {@link superFunc(int,String) \n" +
    		" Test for std_string member \n" +
    		" }\n" +
    		" \n" +
    		" {@link superFunc(int,int,SWIGTYPE_p_void) \n" +
    		" Test for simple types \n" +
    		" }\n" +
    		" \n" +
    		" {@link superFunc(SWIGTYPE_p_p_Shape) \n" +
    		" Test for custom types \n" +
    		" }\n" +
    		" \n" +
    		" {@link superFunc(SWIGTYPE_p_p_p_int) \n" +
    		" Test for complex types \n" +
    		" }\n" +
    		" \n" +
    		" same works for 'See also:' links: \n" +
    		" \n" +
    		" @see superFunc(int,String)\n" +
    		" @see superFunc(int,int,SWIGTYPE_p_void)\n" +
    		" @see superFunc(SWIGTYPE_p_p_Shape)\n" +
    		" @see superFunc(SWIGTYPE_p_p_p_int)\n" +
    		" \n" +
    		" some failing params: \n" +
    		" \n" +
    		" @see superFunc() \n" +
    		" @see superFunc() \n" +
    		" @see superFunc() \n" +
    		" \n" +
    		" \n" +
    		"");
    
    // and ask the parser to check comments for us
    System.exit(CommentParser.check(wantedComments));
  }
}