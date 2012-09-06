
import doxygen_misc_constructs.*;
import com.sun.javadoc.*;
import java.util.HashMap;

public class doxygen_misc_constructs_runme {
  static {
    try {
      System.loadLibrary("doxygen_misc_constructs");
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
    com.sun.tools.javadoc.Main.execute("doxygen_misc_constructs runtime test",
	"commentParser", new String[]{"-quiet", "doxygen_misc_constructs"});

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.getConnection()",
    		" \n" +
    		" \n" +
    		" This function returns connection id. \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.getAddress(doxygen_misc_constructs.SWIGTYPE_p_int, int)",
    		" Returns address of file line. \n" +
    		" \n" +
    		" @param fileName name of the file, where the source line is located \n" +
    		" @param line line number \n" +
    		" {@link Connection::getId()  }<br> \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.getG_zipCode()",
    		" Tag endlink must be recognized also when it is the last token \n" +
    		" in the commment. \n" +
    		" \n" +
    		" {@link Connection::getId()  }<br> \n" +
    		" {@link debugIdeTraceProfilerCoverageSample.py Python example.  }\n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.setG_zipCode(int)",
    		" Tag endlink must be recognized also when it is the last token \n" +
    		" in the commment. \n" +
    		" \n" +
    		" {@link Connection::getId()  }<br> \n" +
    		" {@link debugIdeTraceProfilerCoverageSample.py Python example.  }\n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.getG_counter()",
    		" Tag endlink must be recognized also when followed by nonspace charater. \n" +
    		" \n" +
    		" {@link Connection::getId()  }<br> \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.waitTime(int)",
    		" Determines how long the <code>isystem.connect</code> should wait for running \n" +
    		" instances to respond. Only one of <code>lfWaitXXX</code> flags from IConnect::ELaunchFlags \n" +
    		" may be specified. \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.CConnectionConfig",
    		" This class contains information for connection to winIDEA. Its methods \n" +
    		" return reference to self, so we can use it like this: \n" +
    		" <pre> \n" +
    		" CConnectionConfig config = new CConnectionConfig(); \n" +
    		" config.discoveryPort(5534).dllPath(\"C: \\ yWinIDEA \\ onnect.dll\").id(\"main\"); \n" +
    		" </pre> \n" +
    		" \n" +
    		" All parameters are optional. Set only what is required, default values are \n" +
    		" used for unspecified parameters. \n" +
    		" <p> \n" +
    		" \n" +
    		" {@link advancedWinIDEALaunching.py Python example.  }<br> \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.getAddress(doxygen_misc_constructs.SWIGTYPE_p_int, int, boolean)",
    		" Returns address of file line. \n" +
    		" \n" +
    		" @param fileName name of the file, where the source line is located \n" +
    		" @param line line number \n" +
    		" @param isGetSize if set, for every object location both address and size are returned \n" +
    		" \n" +
    		" {@link Connection::getId()  }<br> \n" +
    		" \n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.setG_counter(char)",
    		" Tag endlink must be recognized also when followed by nonspace charater. \n" +
    		" \n" +
    		" {@link Connection::getId()  }<br> \n" +
    		" \n" +
    		"");

    wantedComments.put("doxygen_misc_constructs.ClassWithNestedEnum",
    		" Class description.\n" +
    		" \n");

    wantedComments.put("doxygen_misc_constructs.ClassWithNestedEnum.ENested",
    		" Enum description.\n" +
    		" \n");

    wantedComments.put("doxygen_misc_constructs.ClassWithNestedEnum.ENested.ONE",
    		" desc of one\n" +
    		" \n");

    wantedComments.put("doxygen_misc_constructs.ClassWithNestedEnum.ENested.TWO",
    		" desc of two\n" +
    		" \n");

    wantedComments.put("doxygen_misc_constructs.ClassWithNestedEnum.ENested.THREE",
    		" desc of three\n" +
    		" \n");

    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.isNoSpaceValidA()",
    		" This comment without space after '*' is valid in Doxygen. \n" +
    		" \n" +
    		"");
 
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.isNoSpaceValidB()",
    		" .This comment without space after '*' is valid in Doxygen. \n" +
    		" \n" +
    		"");
 
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.backslashA()",
    		" Backslash following<code>word</code> is valid doxygen command. Output contains \n" +
    		" 'followingword' with word in 'code' font. \n" +
    		" \n" +
    		"");
 
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.backslashB()",
                       " Doxy command without trailing cspace space is ignored. Standalone \n" +
                       " \\ and '\\' get to output. Commands not recognized by Doxygen \n" +
                       " are ignored. Backslashes in DOS paths d: and words \n" +
                       " following them do not appear on output, we must quote them with \n" +
                       " double quotes: \"d:\\xyz\\c\\myfile\", single quotes do not help: \n" +
                       " 'd: '. Escaping works: d:\\xyz\\c\\myfile. Unix \n" +
                       " paths of course have no such problems: /xyz/c/myfile \n" +
    		" \n");
 
    // and ask the parser to check comments for us
    System.exit(parser.check(wantedComments));
  }
}