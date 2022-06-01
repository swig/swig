
import doxygen_parsing.*;
import java.util.HashMap;

public class doxygen_parsing_runme {
  static {
    try {
      System.loadLibrary("doxygen_parsing");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
    CommentParser.parse("doxygen_parsing");

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    
    wantedComments.put("doxygen_parsing.SomeAnotherClass",
    		" SomeAnotherClass description");
    wantedComments.put("doxygen_parsing.SomeAnotherClass(int)",
    		" First overloaded constructor.");
    wantedComments.put("doxygen_parsing.SomeAnotherClass(java.lang.String)",
    		" Second overloaded constructor.");
    wantedComments.put("doxygen_parsing.SomeAnotherClass.getClassAttr()",
    		" The class attribute comment \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherClass.setClassAttr3(int)",
    		"The class attribute post-comment with details \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherStruct.setStructAttr3(int)",
    		"The struct attribute post-comment with details \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherClass.classMethodExtended2(int, int)",
    		" The class method with parameter \n" +
    		" \n" +
    		" @param a Parameter a \n" +
    		" @param b Parameter b \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeStruct",
    		" The struct comment \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeStruct.setWidth(int)",
    		"**immutable** image width in pixels \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeStruct.getWidth()",
    		"**immutable** image width in pixels \n" +
    		"");
    wantedComments.put("doxygen_parsing.doxygen_parsing.setSomeVar(int)",
    		" The var comment \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherStruct.structMethod()",
    		" The struct method comment \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.doxygen_parsing.someFunction()",
    		" The function comment \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherClass.classMethodExtended(int, int)",
    		" The class method with parameter \n" +
    		" \n" +
    		" @param a Parameter a \n" +
    		" @param b Parameter b \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherClass.setClassAttr(int)",
    		" The class attribute comment \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherStruct.structMethodExtended(int, int)",
    		" The struct method with parameter \n" +
    		" \n" +
    		" @param a Parameter a \n" +
    		" @param b Parameter b \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherStruct.getStructAttr()",
    		" The struct attribute comment \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeClass",
    		" The class comment \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherStruct.getStructAttr3()",
    		"The struct attribute post-comment with details \n" +
    		"");
    wantedComments.put("doxygen_parsing.doxygen_parsing.getSomeVar()",
    		" The var comment \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherStruct.setStructAttr2(int)",
    		"The struct attribute post-comment \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherClass.getClassAttr2()",
    		"The class attribute post-comment \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherStruct.getStructAttr2()",
    		"The struct attribute post-comment \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherStruct.setStructAttr(int)",
    		" The struct attribute comment \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeEnum",
    		" The enum comment \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherClass.getClassAttr3()",
    		"The class attribute post-comment with details \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherClass.classMethod()",
    		" The class method comment.<br>\n" +
                " <br>\n" +
                " {@link SomeAnotherClass#classMethodExtended(int,int) a link text  }\n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherStruct.structMethodExtended2(int, int)",
    		" The struct method with parameter \n" +
    		" \n" +
    		" @param a Parameter a \n" +
    		" @param b Parameter b \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_parsing.SomeAnotherClass.setClassAttr2(int)",
    		"The class attribute post-comment \n" +
    		"");
    wantedComments.put("doxygen_parsing.doxygen_parsingConstants.CONSTANT_VALUE",
    		"The constant comment \n" +
    		"");
    wantedComments.put("doxygen_parsing.Foo1750.getA()",
	        "");
    wantedComments.put("doxygen_parsing.Foo1750.getB()",
	        "");
    wantedComments.put("doxygen_parsing.Foo1750.setA(int)",
	        "");
    wantedComments.put("doxygen_parsing.Foo1750.setB(int)",
	        "");
    
    // and ask the parser to check comments for us
    System.exit(CommentParser.check(wantedComments));
  }
}
