
import doxygen_parsing.*;
import com.sun.javadoc.*;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Iterator;

public class doxygen_parsing_runme {
  static {
    try {
      System.loadLibrary("doxygen_parsing");
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
    com.sun.tools.javadoc.Main.execute("doxygen_parsing runtime test",
	"doxygen_parsing_runme", new String[]{"-quiet", "doxygen_parsing"});

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
