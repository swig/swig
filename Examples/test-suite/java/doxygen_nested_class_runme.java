import doxygen_nested_class.*;
import com.sun.javadoc.*;
import java.util.HashMap;

public class doxygen_nested_class_runme {
  static {
    try {
      System.loadLibrary("doxygen_nested_class");
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
    CommentParser parser = new CommentParser();
    com.sun.tools.javadoc.Main.execute("doxygen_nested_class runtime test",
                                       "CommentParser",
                                       new String[]{"-quiet", "doxygen_nested_class"});

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    
    wantedComments.put("doxygen_nested_class.DoxOuter()",
    		" DoxOuter constructor ");
    wantedComments.put("doxygen_nested_class.DoxOuter.DoxInner",
    		" DoxInner class description ");
    wantedComments.put("doxygen_nested_class.DoxOuter.DoxInner()",
    		" DoxInner constructor ");
    wantedComments.put("doxygen_nested_class.DoxOuter.DoxInner.setDoxInt(int)",
    		" doxInt variable ");
    wantedComments.put("doxygen_nested_class.DoxOuter.DoxInner.getDoxInt()",
    		" doxInt variable ");
    wantedComments.put("doxygen_nested_class.DoxOuter.DoxInner.doxMethod()",
    		" doxMethod description ");
    wantedComments.put("doxygen_nested_class.DoxOuter.DoxInner.doxStaticMethod()",
    		" doxStaticMethod description ");
    wantedComments.put("doxygen_nested_class.DoxOuter.DoxInner.doxShort",
    		" doxShort const variable ");
    
    // and ask the parser to check comments for us
    System.exit(parser.check(wantedComments));
  }
}
