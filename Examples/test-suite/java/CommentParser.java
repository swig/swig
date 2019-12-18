
import com.sun.source.doctree.*;
import com.sun.source.util.DocTrees;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Map;
import java.util.Set;
import java.util.Iterator;
import java.io.BufferedWriter;
import java.io.OutputStreamWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.*;
import java.util.spi.ToolProvider;
import javax.lang.model.*;
import javax.lang.model.element.*;
import javax.lang.model.util.*;
import jdk.javadoc.doclet.*;


public class CommentParser implements Doclet {
    private static Map<String, String> m_parsedComments = new HashMap<String, String>();

    // We need to implement these base class pure virtual methods.

    @Override
    public void init(Locale locale, Reporter reporter) {
    }

    @Override
    public Set<? extends Option> getSupportedOptions() {
        return new HashSet<>();
    }

    @Override
    public SourceVersion getSupportedSourceVersion() {
        return SourceVersion.latest();
    }

    @Override
    public String getName() {
        return "CommentParser";
    }

    // Element name must be the fully qualified name of the element.
    //
    // If there is no comment associated with this element, simply do nothing.
    private void storeCommentFor(DocTrees docTrees, String fullName, Element e) {
        DocCommentTree docCommentTree = docTrees.getDocCommentTree(e);
        if (docCommentTree == null)
            return;

        StringBuilder name = new StringBuilder(fullName);

        // We must use signature in the key for methods for compatibility with
        // the existing tests and to allow distinguishing between overloaded
        // methods.
        if (e instanceof ExecutableElement) {
            ExecutableElement ex = (ExecutableElement)e;
            name.append("(");

            boolean firstParam = true;
            for (VariableElement p : ex.getParameters()) {
                if (firstParam) {
                    firstParam = false;
                } else {
                    name.append(", ");
                }

                name.append(p.asType().toString());
            }

            name.append(")");
        }

        // For some reason the comment in the source is split into "body" and
        // "block tags" parts, so we need to concatenate them back together.
        StringBuilder comment = new StringBuilder();
        for (DocTree d : docCommentTree.getFullBody()) {
            comment.append(d.toString());
            comment.append("\n");
        }

        boolean firstBlockTag = true;
        for (DocTree d : docCommentTree.getBlockTags()) {
            if (firstBlockTag) {
                firstBlockTag = false;
                comment.append("\n");
            }

            comment.append(d.toString());
            comment.append("\n");
        }

        m_parsedComments.put(name.toString(), comment.toString());
    }

    @Override
    public boolean run(DocletEnvironment docEnv) {
        /*
         * This method is called by 'javadoc' and gets the whole parsed java
         * file, we get comments and store them
         */
        DocTrees docTrees = docEnv.getDocTrees();
        for (TypeElement t : ElementFilter.typesIn(docEnv.getIncludedElements())) {
            String typeName = t.getQualifiedName().toString();

            storeCommentFor(docTrees, typeName, t);

            for (Element e : t.getEnclosedElements()) {
                // Omit the method name for ctors: this is a bit weird, but
                // this is what the existing tests expect.
                String fullName = typeName;
                if (e.getKind() != ElementKind.CONSTRUCTOR) {
                    fullName = fullName + "." + e.getSimpleName();
                }

                storeCommentFor(docTrees, fullName, e);
            }
        }

        return true;
    }

    
    public static int check(Map<String, String> wantedComments) {
        int errorCount=0;
        Iterator<Entry<String, String>> it = m_parsedComments.entrySet().iterator();

        while (it.hasNext()) {
            
            Entry<String, String> e = (Entry<String, String>) it.next();
            String actualStr = e.getValue();
            String wantedStr = wantedComments.get(e.getKey());
            // this may be weird, but I don't know any more effective solution
            actualStr = actualStr.replace(" ", "");
            actualStr = actualStr.replaceAll("\t", "");
            actualStr = actualStr.replace("\n", "");
            
            // Removing of <br> is temporary solution, since adding of
            // <br> tag requires changes in all tests. However, <br>
            // tag should be added more selectively and when this is
            // implemented, tests should be updated.
            actualStr = actualStr.replace("<br>", "");
            
            if (wantedStr != null) {
                wantedStr = wantedStr.replace(" ", "");
                wantedStr = wantedStr.replace("\t", "");
                wantedStr = wantedStr.replace("\n", "");
                wantedStr = wantedStr.replace("<br>", "");
            }
            /* The following lines replace multiple whitespaces with a single one.
               Although this would be more exact testing, it would also require
               more work on test maintenance.
            actualStr = actualStr.replace('\t', ' ');
            actualStr = actualStr.replaceAll(" +", " ");
            // actualStr = actualStr.replace("\n", "");
            if (wantedStr != null) {
                wantedStr = wantedStr.replace('\t', ' ');
                wantedStr = wantedStr.replaceAll(" +", " ");
                // wantedStr = wantedStr.replace("\n", "");
                } */

            if (!actualStr.equals(wantedStr)) {
                System.out.println("\n\n////////////////////////////////////////////////////////////////////////");
                System.out.println("Documentation comments for '" + e.getKey() + "' do not match!");
                String expectedFileName = "expected.txt";
                String gotFileName = "got.txt";
                System.out.println("Output is also saved to files '" + expectedFileName +
                                   "' and '" + gotFileName + "'");
                // here we print original strings, for nicer output
                System.out.println("\n\n---\nexpected:\n" + wantedStr);
                System.out.println("\n\n---\ngot:\n" + e.getValue());

                try {
                    // write expected string to file
                    BufferedWriter expectedFile = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(expectedFileName)));
                    if (wantedStr != null)
                        expectedFile.write(wantedStr);
                    expectedFile.close();

                    // write translated string to file
                    BufferedWriter gotFile = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(gotFileName)));
                    gotFile.write(e.getValue().replace("<br>", ""));
                    gotFile.close();
                } catch (IOException ex) {
                    System.out.println("Error when writing output to file: " + ex);
                }
                
                errorCount++;
            }
        }

        if (m_parsedComments.size() != wantedComments.size()) {
            System.out.println("Mismatch in the number of comments!\n    Expected: " +
                               wantedComments.size() + "\n    Parsed: " +
                               m_parsedComments.size());
            System.out.println("Expected keys: ");
            printKeys(wantedComments);
            System.out.println("Parsed keys: ");
            printKeys(m_parsedComments);

            errorCount++;
        }
		
        return errorCount > 0 ? 1 : 0;
    }

    
    private static void printKeys(Map<String, String> map) {
        
        Set<String> keys = map.keySet();
        for (String key : keys) {
            System.out.println("    " + key);
        }
    }
    
    
    public static void printCommentListForJavaSource() {

        Iterator< Entry<String, String> > it = m_parsedComments.entrySet().iterator();
        
        while (it.hasNext())  {
            
            Entry<String, String> e = (Entry<String, String>) it.next();
            String commentText = e.getValue();
            commentText = commentText.replace("\\", "\\\\");
            commentText = commentText.replace("\"", "\\\"");
            commentText = commentText.replace("\n", "\\n\" +\n\t\t\"");
            System.out.format("wantedComments.put(\"%s\",\n\t\t\"%s\");\n", e.getKey(), commentText);
        }
    }

    public static void parse(String sourcefile) {
        ToolProvider javadoc = ToolProvider.findFirst("javadoc").orElseThrow();
        int result = javadoc.run(System.out, System.err, new String[]{"-quiet", "-doclet", "CommentParser", sourcefile});
        if (result != 0) {
          System.err.println("Executing javadoc failed.");
          System.exit(result);
        }
    }

    
    public static void main(String argv[]) {
		
        if (argv.length<1) {
            System.out.format("Usage:\n\tCommentParser <package to parse>\n");
            System.exit(1);
        }
		
        parse(argv[0]);
		
        // if we are run as standalone app, print the list of found comments as it would appear in java source
		
        printCommentListForJavaSource();
    }
}
