
import doxygen_translate_all_tags.*;
import java.util.HashMap;

public class doxygen_translate_all_tags_runme {
  static {
    try {
      System.loadLibrary("doxygen_translate_all_tags");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }
  
  public static void main(String argv[]) 
  {
    CommentParser.parse("doxygen_translate_all_tags");

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    
    wantedComments.put("doxygen_translate_all_tags.doxygen_translate_all_tags.func01(int)",
    		" <i>Hello </i>\n\n\n" +
                " <a id=\"theAnchor\"></a>\n\n\n" +
    		" <li>some list item</li>\n\n" +
    		" This is attention!\n" +
    		" You were warned!\n" +
    		" @author lots of them\n" +
    		" @author Zubr\n\n" +
    		" <b>boldword</b>\n\n" +
    		" Some brief description,\n" +
    		" extended to many lines.\n\n" +
    		" Not everything works right now...\n" +
    		" <code>codeword</code>\n\n\n\n\n\n" +
    		" <i>citationword</i>\n" +
                " {@code some test code }\n\n" +
    		" Code immediately following text.  Pydoc translation must add an\n" +
    		" empty line before:\n" +
    		" {@code more test code }");
    
    wantedComments.put("doxygen_translate_all_tags.doxygen_translate_all_tags.func02(int)",
    		" Conditional comment: SOMECONDITION \n" +
    		" Some conditional comment \n" +
    		" End of conditional comment.\n" +
    		" Copyright: some copyright \n" +
    		" 1970 - 2012 \n" +
    		" @deprecated Now use another function \n" +
    		" This is very large \n" +
    		" and detailed description of some thing \n");
    
    wantedComments.put("doxygen_translate_all_tags.doxygen_translate_all_tags.func03(int)",
                       " Comment for <b>func03()</b>.\n" +
                       " <i>italicword </i>\n" +
    		" <i>emphazedWord </i>\n" +
                " @ example someFile.txt\n" +
                " Some details on using the example");
    
    wantedComments.put("doxygen_translate_all_tags.doxygen_translate_all_tags.func04(int)",
                       " @exception SuperError \n" +
                       " \\sqrt{(x_2-x_1)^2+(y_2-y_1)^2} \n" +
                       " \\sqrt{(x_2-x_1)^2+(y_2-y_1)^2} \n" +
                       " \\sqrt{(x_2-x_1)^2+(y_2-y_1)^2} \n\n" +
                       "Math immediately following text.  Pydoc translation must add an\n" +
                       "empty line before:\n\n" +
                       " \\sqrt{(x_2-x_1)^2+(y_2-y_1)^2}\n" +
                       " This will only appear in hmtl \n");
    
    wantedComments.put("doxygen_translate_all_tags.doxygen_translate_all_tags.func05(int)",
                       " If: ANOTHERCONDITION {\n" +
    		" First part of comment \n" +
    		" If: SECONDCONDITION {\n" +
    		" Nested condition text \n" +
    		" }Else if: THIRDCONDITION {\n" +
    		" The third condition text \n" +
    		" }Else:  {The last text block \n" +
    		" }\n" +
    		" }Else:  {Second part of comment \n" +
    		" If: CONDITION {\n" +
    		" Second part extended \n" +
    		" }\n" +
    		" }\n" +
    		" If not: SOMECONDITION {\n" +
    		" This is printed if not \n" +
    		" }\n" +
    		" <img src=\"testImage.bmp\" alt=\"Hello, world!\"/>\n" +
    		" Some text \n" +
    		" describing invariant. \n");
    
    wantedComments.put("doxygen_translate_all_tags.doxygen_translate_all_tags.func06(int)",
                       " Comment for <b>func06()</b>.\n" +
                       " This will only appear in LATeX \n" +
    		" <ul> \n" +
    		" <li>Some unordered list \n" +
    		" </li><li>With lots of items \n" +
    		" </li><li>lots of lots of items \n" +
    		" </li></ul> \n" +
    		" {@link someMember Some description follows} with text after\n" +
    		" This will only appear in man\n");
    
    wantedComments.put("doxygen_translate_all_tags.doxygen_translate_all_tags.func07(int, int, int, int)",
                       " Comment for <b>func07()</b>.\n" +
                       " Note: Here \n" +
    		" is the note! \n" +
    		" This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.\n" +
    		" <code>someword </code>\n" +
    		" @package superPackage \n" +
    		" <p alt=\"The paragraph title \">\n" +
    		" The paragraph text. \n" +
    		" Maybe even multiline \n" +
    		" </p>\n" +
                " @param a the first param\n" +
                " @param b parameter with intent(in)\n" +
                " @param c parameter with intent(out)\n" +
		" @param d parameter with intent(in,out)\n");
    
    wantedComments.put("doxygen_translate_all_tags.doxygen_translate_all_tags.func08(int)",
                       "<a id=\"someAnchor\"></a>\n" +
                       "Text after anchor.\n" + 
                       "<a href=\"#someAnchor\">Anchor description</a>\n" +
                       "<a href=\"#someAnchor\">someAnchor</a> not quoted text is not part of ref tag\n" +
                       "<a href=\"#someAnchor\">someAnchor</a>\n" +
                       " Remarks: Some remark text \n" +
                       " Remarks: Another remarks section \n" +
                       " @return Whatever \n" +
                       " @return it \n" +
                       " @return may return \n");
    
    wantedComments.put("doxygen_translate_all_tags.doxygen_translate_all_tags.func09(int)",
                       " This will only appear in RTF \n" +
    		" @see someOtherMethod \n" +
    		" @see function \n" +
    		" Same as \n" +
    		" brief description \n" +
    		" @since version 0.0.0.1 \n" +
    		" @throws superException \n" +
    		" @throws RuntimeError \n");
    
    wantedComments.put("doxygen_translate_all_tags.doxygen_translate_all_tags.func10(int, float)",
                       " TODO: Some very important task \n" +
    		" @param b B is mentioned again... \n" +
    		" {@literal \n" +
    		"very long \n" +
    		"text with tags <sometag> \n" +
    		" }\n" +
    		" @version 0.0.0.2 \n" +
    		" Warning: This is senseless! \n" +
    		" This will only appear in XML \n" +
    		" Here goes test of symbols: \n" +
    		" $ @ \\ &amp; ~ &lt; &gt; # % &quot; . :: \n" +
    		" And here goes simple text \n" +
    		"");
    // and ask the parser to check comments for us
    System.exit(CommentParser.check(wantedComments));
  }
}
