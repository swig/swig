
import com.sun.javadoc.*;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Map;
import java.util.Set;
import java.util.Iterator;
import java.io.BufferedWriter;
import java.io.OutputStreamWriter;
import java.io.FileOutputStream;
import java.io.IOException;


public class CommentParser {
    private static Map<String, String> m_parsedComments = new HashMap<String, String>();

    public static boolean start(RootDoc root) {

        /*
         * This method is called by 'javadoc' and gets the whole parsed java
         * file, we get comments and store them
         */

        for (ClassDoc classDoc : root.classes()) {

            if (classDoc.getRawCommentText().length() > 0)
                m_parsedComments.put(classDoc.qualifiedName(), classDoc.getRawCommentText());

            for (FieldDoc f : classDoc.enumConstants()) {
                if (f.getRawCommentText().length() > 0)
                    m_parsedComments.put(f.qualifiedName(), f.getRawCommentText());
            }
            for (FieldDoc f : classDoc.fields()) {
                if (f.getRawCommentText().length() > 0)
                    m_parsedComments.put(f.qualifiedName(), f.getRawCommentText());
            }
            for (ConstructorDoc c : classDoc.constructors()) {
                if (c.getRawCommentText().length() > 0)
                    m_parsedComments.put(c.toString(), c.getRawCommentText());
            }
            for (MethodDoc m : classDoc.methods()) {
                if (m.getRawCommentText().length() > 0)
                    m_parsedComments.put(m.toString(), m.getRawCommentText());
            }
        }
        return true;
    }

    
    public int check(Map<String, String> wantedComments) {
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
                System.out.println("\n\n---\nexpected:\n" + wantedComments.get(e.getKey()));
                System.out.println("\n\n---\ngot:\n" + e.getValue());

                try {
                    // write expected string to file
                    BufferedWriter expectedFile = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(expectedFileName)));
                    expectedFile.write(wantedComments.get(e.getKey()));
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

    
    private void printKeys(Map<String, String> map) {
        
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

    
    public static void main(String argv[]) {
		
        if (argv.length<1) {
            System.out.format("Usage:\n\tCommentParser <package to parse>\n");
            System.exit(1);
        }
		
        com.sun.tools.javadoc.Main.execute("The comment parser program",
                                           "CommentParser", new String[]{"-quiet", argv[0]});
		
        // if we are run as standalone app, print the list of found comments as it would appear in java source
		
        printCommentListForJavaSource();
    }
}
