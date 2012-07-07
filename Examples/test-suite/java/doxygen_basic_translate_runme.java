
import doxygen_basic_translate.*;
import com.sun.javadoc.*;
import java.util.HashMap;

public class doxygen_basic_translate_runme {
  static {
    try {
      System.loadLibrary("doxygen_basic_translate");
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
    com.sun.tools.javadoc.Main.execute("doxygen_basic_translate runtime test",
	"commentParser", new String[]{"-quiet", "doxygen_basic_translate"});

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    
    wantedComments.put("function", " Brief description.  \n The comment text  \n" +
			   " @author\tSome author  \n" +
			   " @return\tSome number  \n" +
			   " @see\tfunction2  \n");
    
    // and ask the parser to check comments for us
    System.exit(parser.check(wantedComments));
  }
}