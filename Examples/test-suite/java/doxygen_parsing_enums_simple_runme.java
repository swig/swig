
import doxygen_parsing_enums_simple.*;
import java.util.HashMap;

public class doxygen_parsing_enums_simple_runme {
  static {
    try {
      System.loadLibrary("doxygen_parsing_enums_simple");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }
  
  public static void main(String argv[]) 
  {
    CommentParser.parse("doxygen_parsing_enums_simple");

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    
    wantedComments.put("doxygen_parsing_enums_simple.doxygen_parsing_enums_simpleConstants.SOME_ITEM_30",
    		"Post comment for the third item \n" +
    		"");
    wantedComments.put("doxygen_parsing_enums_simple.doxygen_parsing_enums_simpleConstants.SOME_ITEM_3",
    		" The comment for the third item \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing_enums_simple.doxygen_parsing_enums_simpleConstants.SOME_ITEM_2",
    		" The comment for the second item \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing_enums_simple.doxygen_parsing_enums_simpleConstants.SOME_ITEM_10",
    		"Post comment for the first item \n" +
    		"");
    wantedComments.put("doxygen_parsing_enums_simple.doxygen_parsing_enums_simpleConstants.SOME_ITEM_20",
    		"Post comment for the second item \n" +
    		"");
    wantedComments.put("doxygen_parsing_enums_simple.doxygen_parsing_enums_simpleConstants.SOME_ITEM_1",
    		" The comment for the first item \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing_enums_simple.doxygen_parsing_enums_simpleConstants.SOME_ITEM_100",
    		"Post comment after comma.");
    wantedComments.put("doxygen_parsing_enums_simple.doxygen_parsing_enums_simpleConstants.SOME_ITEM_200",
    		"Post comment after last comma.");
    
    // and ask the parser to check comments for us
    System.exit(CommentParser.check(wantedComments));
  }
}
