
import doxygen_parsing_enums_simple.*;
import com.sun.javadoc.*;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Iterator;

public class doxygen_parsing_enums_simple_runme {
  static {
    try {
      System.loadLibrary("doxygen_parsing_enums_simple");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  static HashMap<String, String> parsedComments = new HashMap<String, String>();
  static HashMap<String, String> wantedComments = new HashMap<String, String>();

  public static boolean start(RootDoc root) {
    
    /*
      This method is called by 'javadoc' and gets the whole parsed
      java file, we get comments and store them
    */

    ClassDoc[] classes = root.classes();

    for (int i = 0; i < classes.length; i++) {

      if (classes[i].getRawCommentText().length() > 0)
	parsedComments.put(classes[i].name(), classes[i].getRawCommentText());

      MethodDoc[] methods = classes[i].methods();
      FieldDoc[] fields = classes[i].fields();
      FieldDoc[] constants = classes[i].enumConstants();

      for (int j = 0; j < constants.length; j++) {
        FieldDoc f = constants[j];
	if (f.getRawCommentText().length() > 0)
	  parsedComments.put(f.name(), f.getRawCommentText());
      }
      for (int j = 0; j < fields.length; j++) {
        FieldDoc f = fields[j];
	if (f.getRawCommentText().length() > 0)
	  parsedComments.put(f.name(), f.getRawCommentText());
      }
      for (int j = 0; j < methods.length; j++) {
        MethodDoc m = methods[j];
	if (m.getRawCommentText().length() > 0)
	  parsedComments.put(m.name(), m.getRawCommentText());
      }
    }
    return true;
  }

  public static void main(String argv[]) 
  {
    /*
      Here we are using internal javadoc tool, it accepts the name of the class as paramterer,
      and calls the start() method of that class with parsed information.
    */
    com.sun.tools.javadoc.Main.execute("doxygen_parsing_enums_simple runtime test",
	"doxygen_parsing_enums_simple_runme", new String[]{"-quiet", "doxygen_parsing_enums_simple"});

    wantedComments.put("E_TEST_ONE", " the first item  \n");
    wantedComments.put("E_TEST_TWO", " the second  \n");

    int errorCount=0;
    Iterator< Entry<String, String> > it = parsedComments.entrySet().iterator();

    while (it.hasNext())
    {
	Entry<String, String> e = (Entry<String, String>) it.next();

	if (!e.getValue().equals(wantedComments.get(e.getKey()))) {
	    System.out.println("Documentation comments for " + e.getKey() + " does not match: ");
	    System.out.println("\texpected:"+wantedComments.get(e.getKey()));
	    System.out.println("\tgot:\t"+e.getValue());
	    errorCount++;
	}
    }

    if (parsedComments.size() != wantedComments.size()) {
	System.out.println("Found " + (wantedComments.size()-parsedComments.size()) + " missed comment(s)!");
	errorCount++;
    }

    System.exit(errorCount);
  }
}
