
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
    
    wantedComments.put("someFunction", " The function comment \n");
    wantedComments.put("SomeEnum", " The enum comment \n");
    wantedComments.put("setSomeVar", " The var comment \n");
    wantedComments.put("getSomeVar", " The var comment \n");
    wantedComments.put("SomeClass", " The class comment \n");
    wantedComments.put("setClassAttr", " The class attribute comment \n");
    wantedComments.put("getClassAttr", " The class attribute comment \n");
    wantedComments.put("setClassAttr2", " The class attribute post-comment \n");
    wantedComments.put("getClassAttr2", " The class attribute post-comment \n");
    wantedComments.put("setClassAttr3", " The class attribute post-comment with details \n");
    wantedComments.put("getClassAttr3", " The class attribute post-comment with details \n");
    wantedComments.put("classMethod", " The class method comment \n");
    wantedComments.put("classMethodExtended", " The class method with parameter \n @param	a Parameter a \n @param	b Parameter b \n");
    wantedComments.put("classMethodExtended2", " The class method with parameter \n @param	a Parameter a \n @param	b Parameter b \n");
    wantedComments.put("SomeStruct", " The struct comment \n");
    wantedComments.put("setStructAttr", " The struct attribute comment \n");
    wantedComments.put("getStructAttr", " The struct attribute comment \n");
    wantedComments.put("setStructAttr2", " The struct attribute post-comment \n");
    wantedComments.put("getStructAttr2", " The struct attribute post-comment \n");
    wantedComments.put("setStructAttr3", " The struct attribute post-comment with details \n");
    wantedComments.put("getStructAttr3", " The struct attribute post-comment with details \n");
    wantedComments.put("structMethod", " The struct method comment \n");
    wantedComments.put("structMethodExtended", " The struct method with parameter \n @param	a Parameter a \n @param	b Parameter b \n");
    wantedComments.put("structMethodExtended2", " The struct method with parameter \n @param	a Parameter a \n @param	b Parameter b \n");

    // and ask the parser to check comments for us
    System.exit(parser.check(wantedComments));
  }
}
