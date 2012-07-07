
import doxygen_parsing.*;
import com.sun.javadoc.*;
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
    /*
      Here we are using internal javadoc tool, it accepts the name of the class as paramterer,
      and calls the start() method of that class with parsed information.
    */
	commentParser parser = new commentParser();
    com.sun.tools.javadoc.Main.execute("doxygen_parsing runtime test",
	"commentParser", new String[]{"-quiet", "doxygen_parsing"});

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    
    wantedComments.put("simpleFunction", " This is simple comment for a function  \n");

    wantedComments.put("CSimpleClass", " This is simple comment for a class  \n");
    wantedComments.put("simpleMethod", " Simple method  \n");
    wantedComments.put("simpleMethodWithParameter", " Simple method with parameter  \n" +
						    " @param\tparam Some test param  \n" +
						    " @param\targument Some test argument  \n");
    wantedComments.put("CTemplateClassInt", " Comment for template class  \n");
    wantedComments.put("templateMethod", " Template method  \n");

    wantedComments.put("setSimpleVar", " This is simple comment for a var  \n");
    wantedComments.put("getSimpleVar", " This is simple comment for a var  \n");
    wantedComments.put("setSimpleVarTwo", " This is another type of comment for a var  \n");
    wantedComments.put("getSimpleVarTwo", " This is another type of comment for a var  \n");
    wantedComments.put("setSimpleVarThree", " This is again another type of comment for a var  \n");
    wantedComments.put("getSimpleVarThree", " This is again another type of comment for a var  \n");
    wantedComments.put("setSimpleVarFour", " This is the last type of comment for a var  \n");
    wantedComments.put("getSimpleVarFour", " This is the last type of comment for a var  \n");
    wantedComments.put("setSimpleVarFive", " This is a post comment  \n");
    wantedComments.put("getSimpleVarFive", " This is a post comment  \n");

    // and ask the parser to check comments for us
    System.exit(parser.check(wantedComments));
  }
}
