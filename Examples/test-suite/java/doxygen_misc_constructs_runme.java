
import doxygen_misc_constructs.*;
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
    CommentParser.parse("doxygen_misc_constructs");

    HashMap<String, String> wantedComments = new HashMap<String, String>();

    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.getConnection()",
    		"\n" +
    		"\n" +
    		" This function returns connection id.\n" +
    		"\n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.getAddress(doxygen_misc_constructs.SWIGTYPE_p_int, int)",
    		" Returns address of file line.\n" +
    		" \n" +
    		" @param fileName name of the file, where the source line is located\n" +
    		" @param line line number\n" +
    		" {@link Connection::getId()  }<br>\n" +
    		"\n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.getG_zipCode()",
    		" Tag endlink must be recognized also when it is the last token\n" +
    		" in the comment.\n" +
    		" \n" +
    		" {@link Connection::getId()  }<br>\n" +
    		" {@link debugIdeTraceProfilerCoverageSample.py Python example.  }\n" +
    		"\n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.setG_zipCode(int)",
    		" Tag endlink must be recognized also when it is the last token\n" +
    		" in the comment.\n" +
    		"\n" +
    		" {@link Connection::getId()  }<br>\n" +
    		" {@link debugIdeTraceProfilerCoverageSample.py Python example.  }\n" +
    		"\n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.getG_counter()",
    		" Tag endlink must be recognized also when followed by nonspace character.\n" +
    		"\n" +
    		" {@link Connection::getId()  }<br>\n" +
    		"\n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.waitTime(int)",
    		" Determines how long the <code>isystem.connect</code> should wait for running\n" +
    		" instances to respond. Only one of <code>lfWaitXXX</code> flags from IConnect::ELaunchFlags\n" +
    		" may be specified.\n" +
    		"\n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.CConnectionConfig",
    		" This class contains information for connection to winIDEA. Its methods\n" +
    		" return reference to self, so we can use it like this:\n" +
    		" <pre>\n" +
    		" CConnectionConfig config = new CConnectionConfig();\n" +
    		" config.discoveryPort(5534).dllPath(\"C:\\\\myWinIDEA\\\\connect.dll\").id(\"main\");\n" +
    		" </pre>\n" +
    		"\n" +
    		" All parameters are optional. Set only what is required, default values are\n" +
    		" used for unspecified parameters.\n" +
    		" <p>\n" +
    		"\n" +
    		" {@link advancedWinIDEALaunching.py Python example.  }<br>\n" +
    		"\n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.getAddress(doxygen_misc_constructs.SWIGTYPE_p_int, int, boolean)",
    		" Returns address of file line.\n" +
    		"\n" +
    		" @param fileName name of the file, where the source line is located\n" +
    		" @param line line number\n" +
    		" @param isGetSize if set, for every object location both address and size are returned\n" +
    		"\n" +
    		" {@link Connection::getId()  }<br>\n" +
    		"\n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.setG_counter(char)",
    		" Tag endlink must be recognized also when followed by nonspace character.\n" +
    		"\n" +
    		" {@link Connection::getId()  }<br>\n" +
    		"\n" +
    		"");

    wantedComments.put("doxygen_misc_constructs.ClassWithNestedEnum",
    		" Class description.\n" +
    		"\n");

    wantedComments.put("doxygen_misc_constructs.ClassWithNestedEnum.ENested",
    		" Enum description.\n" +
    		"\n");

    wantedComments.put("doxygen_misc_constructs.ClassWithNestedEnum.ENested.ONE",
    		" desc of one\n");

    wantedComments.put("doxygen_misc_constructs.ClassWithNestedEnum.ENested.TWO",
    		" desc of two\n");

    wantedComments.put("doxygen_misc_constructs.ClassWithNestedEnum.ENested.THREE",
    		" desc of three\n");

    wantedComments.put("doxygen_misc_constructs.StructWithReturnComment",
    		" @return This is a bad place for this tag, but it should be ignored.");

    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.showList()",
"         An example of a list in a documentation comment.<br>\n" +
" <br>\n" +
"             - The first item of the list.<br>\n" +
"             - The second list item, on<br>\n" +
"               several indented lines,<br>\n" +
"               showing that the indentation<br>\n" +
"               is preserved.<br>\n" +
"             - And the final list item after it.<br>\n" +
" <br>\n" +
"        And this is not a list item any more.\n" +
    		"");
    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.isNoSpaceValidA()",
    		" This comment without space after '*' is valid in Doxygen.\n" +
    		"\n" +
    		"");

    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.isNoSpaceValidB()",
    		" .This comment without space after '*' is valid in Doxygen.\n" +
    		"\n" +
    		"");

    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.backslashA()",
    		" Backslash following<code>word</code> is a valid doxygen command. Output contains\n" +
    		" 'followingword' with 'word' in code font.\n" +
    		"\n" +
    		"");

    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.backslashB()",
                       " Doxy command without trailing space is ignored - nothing appears\n" +
                       " on output. Standalone \\ and '\\' get to output.\n" +
                       " Standalone @ and '@' get to output.\n" +
                       " Commands \"in quoted \\b strings are treated as plain text\".\n" +
                       " Commands not recognized by Doxygen are ignored.\n" +
                       " Backslashes in DOS paths d:and words\n" +
                       " following them do not appear on output, we must quote them with\n" +
                       " double quotes: \"d:\\xyz\\qwe\\myfile\", \"@something\". Single quotes do not help:\n" +
                       " 'd:'. Escaping works: d:\\xyz\\qwe\\myfile. Unix\n" +
                       " paths of course have no such problems: /xyz/qwe/myfile\n" +
                       " Commands for escaped symbols:\n" +
                       " $ @ \\ &amp; ~ &lt; &gt; # % &quot; . :: @text ::text" +
    		"\n");

   wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.backslashC()",
    		" Backslash e at end of <i>line</i> froze SWIG\n" +
    		" <i>with</i> old comment parser.\n" +
                " @see MyClass#fun(char,float)\n" +
    		"");

   wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.cycle(int, java.lang.String)",
    		" The next line contains expression:\n" +
                " <pre>\n" +
    		" ['retVal &lt; 10', 'g_counter == 23 &amp;&amp; g_mode &amp; 3']\n" +
                " </pre>\n" +
    		"\n" +
                " Both words should be emphasized <b>isystem.connect</b>.\n" +
                " But not the last period. For <b>example</b>, comma should not be emphasized.\n" +
                " Similar <b>for</b>: double colon.\n" +
    		"\n" +
                " Spaces at the start of line should be taken into account:\n" +
                " @param id used as prefix in log\n" +
                "     statements. The default value is empty string, which is OK if\n" +
                "     there is only one app. instance. Example:\n" +
                "     <pre>\n" +
                "         ctrl.setBP(\"func1\");\n" +
                "     </pre>\n" +
                "     If we set the id to <code>main_</code>, we get:\n" +
                "     <pre>\n" +
                "         main_ctrl.setBP(\"func1\");\n" +
                "     </pre>\n" +
                "\n" +
                " @param fileName name of the log file\n");

    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.doc_ends_with_quote()",
            "This doc comment ends with a quote: \"and that's ok\"");

    wantedComments.put("doxygen_misc_constructs.doxygen_misc_constructs.doc_with_triple_quotes()",
            "This comment contains embedded triple-quoted string:\n" +
            "\"\"\"How quaint\"\"\"");

    // and ask the parser to check comments for us
    System.exit(CommentParser.check(wantedComments));
  }
}
