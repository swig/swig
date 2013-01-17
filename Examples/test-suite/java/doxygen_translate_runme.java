
import doxygen_translate.*;
import com.sun.javadoc.*;
import java.util.HashMap;

public class doxygen_translate_runme {
  static {
    try {
      System.loadLibrary("doxygen_translate");
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
    com.sun.tools.javadoc.Main.execute("doxygen_translate runtime test",
	"commentParser", new String[]{"-quiet", "doxygen_translate"});

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    
    wantedComments.put("doxygen_translate.doxygen_translate.function(int, float)",
    		" <i>Hello </i>\n" +
    		" \n" +
    		" <li>some list item</li>\n" +
    		" \n" +
    		" @author lots of them \n" +
    		" \n" +
    		" @author Zubr \n" +
    		" \n" +
    		" <b>boldword </b>\n" +
    		" \n" +
    		" <code>codeword </code>\n" +
    		" \n" +
    		" <i>citationword </i>\n" +
    		" \n" +
    		" {@code some test code }\n" +
    		" \n" +
    		" Conditional comment: SOMECONDITION \n" +
    		" Some conditional comment \n" +
    		" End of conditional comment.\n" +
    		" \n" +
    		" Copyright: some copyright \n" +
    		" \n" +
    		" @deprecated Now use another function \n" +
    		" \n" +
    		" <i>italicword </i>\n" +
    		" \n" +
    		" @ example someFile.txt\n" +
    		" Some details on using the example\n" +
    		" \n" +
                " @exception SuperError \n" +
    		" \n" +
    		" If: ANOTHERCONDITION {\n" +
    		" First part of comment \n" +
    		" If: SECONDCONDITION {\n" +
    		" Nested condition text}\n" +
    		" Else if: THIRDCONDITION {\n" +
    		" The third condition text}\n" +
    		" Else:  {The last text block}}\n" +
    		" \n" +
    		" Else:  {Second part of comment \n" +
    		" If: CONDITION {\n" +
    		" Second part extended}}\n" +
    		" \n" +
    		" \n" +
    		" \n" +
    		" If not: SOMECONDITION {\n" +
    		" This is printed if not}\n" +
    		" \n" +
    		" \n" +
    		" <img src=testImage.bmp alt=\"Hello, world!\" />\n" +
    		" \n" +
    		" <ul> \n" +
    		" \n" +
    		" <li>Some unordered list</li>\n" +
    		" <li>With lots of items</li>\n" +
    		" <li>lots of lots of items</li>\n" +
    		" \n" +
    		" </ul> \n" +
    		" \n" +
    		" {@link someMember Some description follows }\n" +
    		" \n" +
    		" \n" +
    		" \n" +
    		" \n" +
    		" \n" +
    		" \n" +
    		" Note: Here \n" +
    		" is the note! \n" +
    		" \n" +
    		" This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.\n" +
    		" \n" +
    		" <code>someword </code>\n" +
    		" \n" +
    		" @package superPackage \n" +
    		" \n" +
    		" <p alt=\"The paragraph title \">\n" +
    		" The paragraph text. \n" +
    		" Maybe even multiline</p>\n" +
    		" \n" +
    		" @param a the first param \n" +
    		" \n" +
    		" Remarks: Some remark text \n" +
    		" \n" +
    		" Remarks: Another remarks section \n" +
    		" \n" +
    		" @return Whatever \n" +
    		" \n" +
    		" @return it \n" +
    		" \n" +
    		" @return may return \n" +
    		" \n" +
    		" @see someOtherMethod \n" +
    		" \n" +
    		" @see function \n" +
    		" \n" +
    		" @since version 0.0.0.1 \n" +
    		" \n" +
    		" @throws superException \n" +
    		" \n" +
    		" @throws RuntimeError \n" +
    		" \n" +
    		" TODO: Some very important task \n" +
    		" \n" +
    		" @param b B is mentioned again... \n" +
    		" \n" +
    		" {@literal \n" +
    		"very long \n" +
    		"text with tags <sometag> \n" +
    		" }\n" +
    		" \n" +
    		" @version 0.0.0.2 \n" +
    		" \n" +
    		" Warning: This is senseless! \n" +
    		" \n" +
    		" Here goes test of symbols: \n" +
    		" $ @ \\ &amp; ~ &lt; &gt; # % &quot; . :: \n" +
    		" \n" +
    		" And here goes simple text \n" +
    		" \n" +
    		"");
    // and ask the parser to check comments for us
    System.exit(parser.check(wantedComments));
  }
}
