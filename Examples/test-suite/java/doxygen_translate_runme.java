
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

        wantedComments.put("doxygen_translate.doxygen_translate.htmlFunction(int, float)",
    		" Test for html tags. See Doxygen doc for list of tags recognized by Doxygen.          \n" +
    		"                                                                                      \n" +
    		" <a href = \"http://acme.com/index.html\">This is link</a>                               \n" +
    		" <b>bold</b>                                                                          \n" +
    		" <blockquote>                                                                         \n" +
    		" Quotation block.                                                                     \n" +
    		" </blockquote>                                                                        \n" +
    		" <br>                                                                                 \n" +
    		" <center>center</center>                                                              \n" +
    		" <code>this is code</code>                                                            \n" +
    		" <dd> Starts an item description.                                                     \n" +
    		" <dfn> Starts a piece of text displayed in a typewriter font.                         \n" +
    		" </dfn>                                                                               \n" +
    		" <div> Starts a section with a specific style (HTML only)                             \n" +
    		" </div>                                                                               \n" +
    		" <dl> Starts a description list.                                                      \n" +
    		" <dt> Starts an item title.</dt>                                                      \n" +
    		" </dl>                                                                                \n" +
    		" <em> Starts a piece of text displayed in an italic font.                             \n" +
    		" </em>                                                                                \n" +
    		" <form> 'Form' does not generate any output.                                          \n" +
    		" </form>                                                                              \n" +
    		" <hr>                                                                                 \n" +
    		" <h1> Starts an unnumbered section.                                                   \n" +
    		" </h1>                                                                                \n" +
    		" <h2> Starts an unnumbered subsection.                                                \n" +
    		" </h2>                                                                                \n" +
    		" <h3> Starts an unnumbered subsubsection.                                             \n" +
    		" </h3>                                                                                \n" +
    		" <i> Starts a piece of text displayed in an italic font.                              \n" +
    		" <input> Does not generate any output.                                                \n" +
    		" </i>                                                                                 \n" +
    		" <img src=\"slika.png\">                                                                \n" +
    		" <meta> Does not generate any output.                                                 \n" +
    		" <multicol> ignored by doxygen.                                                       \n" +
    		" </multicol> ignored by doxygen.                                                      \n" +
    		"                                                                                      \n" +
    		" <ol> Starts a numbered item list.                                                    \n" +
    		" <li> Starts a new list item.                                                         \n" +
    		" </li>                                                                                \n" +
    		" </ol> Ends a numbered item list.                                                     \n" +
    		"                                                                                      \n" +
    		" <p> Starts a new paragraph.                                                          \n" +
    		" </p>                                                                                 \n" +
    		" <pre> Starts a preformatted fragment.                                                \n" +
    		" </pre>                                                                               \n" +
    		" <small> Starts a section of text displayed in a smaller font.                        \n" +
    		" </small>                                                                             \n" +
    		" <span> Starts an inline text fragment with a specific style (HTML only)              \n" +
    		" </span>                                                                              \n" +
    		" <strong> Starts a section of bold text.                                              \n" +
    		" </strong>                                                                            \n" +
    		" <sub> Starts a piece of text displayed in subscript.                                 \n" +
    		" </sub>                                                                               \n" +
    		" <sup> Starts a piece of text displayed in superscript.                               \n" +
    		" </sup>                                                                               \n" +
    		"                                                                                      \n" +
    		" <table border = '1'>                                                                 \n" +
    		" <caption>Animals</caption>                                                           \n" +
    		" <tr><th> cow   </th><th> dog    </th></tr>                                           \n" +
    		" <tr><td> cow   </td><td> dog    </td></tr>                                           \n" +
    		" <tr><td> cat   </td><td> mouse  </td></tr>                                           \n" +
    		" <tr><td> horse </td><td> parrot </td></tr>                                           \n" +
    		" </table>                                                                             \n" +
    		"                                                                                      \n" +
    		" <tt> Starts a piece of text displayed in a typewriter font.                          \n" +
    		" </tt>                                                                                \n" +
    		" <kbd> Starts a piece of text displayed in a typewriter font.                         \n" +
    		" </kbd>                                                                               \n" +
    		"                                                                                      \n" +
    		" <ul> Starts an unnumbered item list.                                                 \n" +
    		" <li> Starts a new list item 1.</li>                                                  \n" +
    		" <li> Starts a new list item 2.</li>                                                  \n" +
    		" <li> Starts a new list item 3.</li>                                                  \n" +
    		" </ul> Ends an unnumbered item list.                                                  \n" +
    		"                                                                                      \n" +
    		" <var> Starts a piece of text displayed in an italic font.                            \n" +
    		" </var>                                                                               \n" +
                "\n" +
                "<u>underlined \\b bold text - doxy commands are ignored inside 'htmlonly' section </u>\n" +
                "\n" +
                "&lt;u&gt;underlined text&lt;u&gt;\n" +
                "");

        wantedComments.put("doxygen_translate.doxygen_translate.htmlEntitiesFunction(int, float)",
                "All entities are treated as commands &copy; &trade; &reg;\n" +
                "should work also&lt;in text                              \n" +
                "&gt;                                                     \n" +
                "&amp;                                                    \n" +
                "&apos;                                                   \n" +
                "&quot;                                                   \n" +
                "&lsquo;                                                  \n" +
                "&rsquo;                                                  \n" +
                "&ldquo;                                                  \n" +
                "&rdquo;                                                  \n" +
                "&ndash;                                                  \n" +
                "&mdash;                                                  \n" +
                "&nbsp;                                                   \n" +
                "&times;                                                  \n" +
                "&minus;                                                  \n" +
                "&sdot;                                                   \n" +
                "&sim;                                                    \n" +
                "&le;                                                     \n" +
                "&ge;                                                     \n" +
                "&larr;                                                   \n" +
                "&rarr;                                                   \n" +
                "Not an  html entity - ignored by Doxygen.                \n" +
                "Not an &amp;text html entity - ampersand is replaced with entity.\n" +
                "");
        
    // and ask the parser to check comments for us
    System.exit(parser.check(wantedComments));
  }
}
