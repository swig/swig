
import doxygen_translate.*;
import java.util.HashMap;
import java.util.Map;

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
    CommentParser.parse("doxygen_translate");

    Map<String, String> wantedComments = new HashMap<String, String>();
    
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
    		" <img src=testImage.bmp alt=\"Hello, world!\"/>\n" +
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
    		" <a href=\"http://acme.com/index.html\">This is link</a>                               \n" +
    		" <b>bold</b>                                                                          \n" +
    		" <blockquote cite=\"http://www.worldwildlife.org/who/index.html\">                                                                         \n" +
    		" Quotation block.                                                                     \n" +
    		" </blockquote>                                                                        \n" +
    		" <br>                                                                                 \n" +
    		" <center>center</center>                                                              \n" +
    		" <code>this is code</code>                                                            \n" +
                "\n" + 
    		"  <dl>\n" + 
    		"  <dt>Starts an item title.</dt>\n" + 
    		"  <dd>Starts an item description.</dd>\n" + 
    		"  </dl>\n" +
                "\n" + 
    		" <dfn> Starts a piece of text displayed in a typewriter font.                         \n" +
    		" </dfn>                                                                               \n" +
    		" <div> Starts a section with a specific style (HTML only)                             \n" +
    		" </div>                                                                               \n" +
    		" <em> Starts a piece of text displayed in an italic font.</em>                        \n" +
    		"\n" +
    		" <form> 'Form' does not generate any output.                                          \n" +
    		" </form>                                                                              \n" +
    		" <hr>                                                                                 \n" +
    		" <h1> Heading 1                                                   \n" +
    		" </h1>                                                                                \n" +
    		" <h2> Heading 2                                                \n" +
    		" </h2>                                                                                \n" +
    		" <h3> Heading 3                                             \n" +
    		" </h3>                                                                                \n" +
    		" <i>Starts a piece of text displayed in an italic font.</i>                              \n" +
    		" <input>Input tag.                                                \n" +
    		"                                                                                  \n" +
    		" <img src=\"slika.png\">                                                                \n" +
    		" <meta>Meta tag.                                                 \n" +
    		" <multicol>Multicol is ignored by doxygen.                                                       \n" +
    		" </multicol>                                                      \n" +
    		"                                                                                      \n" +
    		" <ol>                                                      \n" +
    		" <li>List item 1.</li>                                                      \n" +
    		" <li>List item 2.</li>                                                      \n" +
    		" </ol>                                                       \n" +
    		"                                                                                      \n" +
    		" <p> Starts a new paragraph.                                                          \n" +
    		" </p>                                                                                 \n" +
    		" <pre> Starts a preformatted fragment.                                                \n" +
    		" </pre>                                                                               \n" +
    		" <small> Starts a section of text displayed in a smaller font.                        \n" +
    		" </small>                                                                             \n" +
    		" <span> Starts an inline text fragment with a specific style.</span>              \n" +
    		"                                                                               \n" +
    		" <strong> Starts a section of bold text.</strong>                                              \n" +
    		" <sub> Starts a piece of text displayed in subscript.</sub>                                 \n" +
    		" <sup> Starts a piece of text displayed in superscript.</sup>                               \n" +
    		"                                                                                      \n" +
    		" <table border = '1'>                                                                 \n" +
    		" <caption>Animals</caption>                                                           \n" +
    		" <tr><th> Column 1   </th><th> Column 2   </th></tr>                                           \n" +
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
    		"  <ul>\n" +
    		"  <li>List item 1.</li>\n" +
    		"  <li>List item 2.</li>\n" +
    		"  <li>List item 3.</li>\n" +
    		"  </ul>\n" +
    		"                                                                                      \n" +
    		" <var> Starts a piece of text displayed in an italic font.</var>                            \n" +
    		"                                                                                \n" +
                "\n" +
                "<u>underlined \\b bold text - doxy commands are ignored inside 'htmlonly' section </u>\n" +
                "\n" +
                "");

        wantedComments.put("doxygen_translate.doxygen_translate.htmlTableFunction(int)",
                "The meaning of flags:\n" +
                "\n" +
                " @param byFlags bits marking required items:\n" +
                "   <table>\n" +
                "   <tr><th> Size in bits</th><th> Items Required </th></tr>\n" +
                "   <tr><td> 1 - 8       </td><td>      1         </td></tr>\n" +
                "   <tr><td> 9 - 16      </td><td>      2         </td></tr>\n" +
                "   <tr><td> 17 - 32     </td><td>      4         </td></tr>\n" +
                "   </table>\n" +
                "   Almost all combinations of above flags are supported by\n" +
                "   <code>htmlTable...</code> functions.\n" +
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
    System.exit(CommentParser.check(wantedComments));
  }
}
