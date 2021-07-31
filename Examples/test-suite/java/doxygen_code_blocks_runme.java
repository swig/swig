
import doxygen_code_blocks.*;
import java.util.HashMap;

public class doxygen_code_blocks_runme {
  static {
    try {
      System.loadLibrary("doxygen_code_blocks");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }
  
  public static void main(String argv[]) 
  {
    CommentParser.parse("doxygen_code_blocks");

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    
    wantedComments.put("doxygen_code_blocks.doxygen_code_blocks.function()",
		       " Test for code blocks\n \n" +
		       " \n \n" +
		       " {@code  \n" +
		       " simple code block \n" +
		       " }\n \n" +
		       " \n \n" +
		       " More advanced usage with C++ characters:\n \n" +
		       " {@code  \n" +
		       " std::vector<int> first;                                // empty vector of ints \n" +
		       " std::vector<int> second (4,100);                       // four ints with value 100 \n" +
		       " std::vector<int> third (second.begin(),second.end());  // iterating through second \n" +
		       " std::vector<int> fourth (third);                       // a copy of third \n" +
		       " // the iterator constructor can also be used to construct from arrays: \n" +
		       " int myints[] = {16,2,77,29}; \n" +
		       " std::vector<int> fifth (myints, myints + sizeof(myints) / sizeof(int) ); \n" +
		       "  \n" +
		       " std::cout << \"The contents of fifth are:\"; \n" +
		       " for (std::vector<int>::iterator it = fifth.begin(); it != fifth.end(); ++it) \n" +
		       " std::cout << \' \' << *it; \n" +
		       " std::cout << \'\\n\';  \n" +
		       " }\n \n" +
		       " \n \n" +
		       " A code block for C:\n \n" +
		       " {@code  \n" +
		       " printf(\"hello world\"); \n" +
		       " }\n \n" +
		       " \n \n" +
		       " A code block for Java:\n \n" +
		       " {@code  \n" +
		       " public class HelloWorld { \n" +
		       " public static void main(String[] args) { \n" +
		       " // Prints \"Hello, World\" to the terminal window. \n" +
		       " System.out.println(\"Hello, World\"); \n" +
		       " } \n" +
		       " } \n" +
		       " }\n \n" +
		       " \n \n" +
		       " A code block for python:\n \n" +
		       " {@code  \n" +
		       " print(\'hello world\') \n" +
		       " }\n \n" +
		       " \n \n" +
		       " A python doctest example:\n \n" +
		       " {@code  \n" +
		       " >>> 1 + 1 \n" +
		       " 2 \n" +
		       " } \n" +
		       " \n" +
		       "");

    // and ask the parser to check comments for us
    System.exit(CommentParser.check(wantedComments));
  }
}
