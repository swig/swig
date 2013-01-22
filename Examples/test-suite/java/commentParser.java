
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


public class commentParser {
    static HashMap<String, String> parsedComments = new HashMap<String, String>();

    public static boolean start(RootDoc root) {

        /*
         * This method is called by 'javadoc' and gets the whole parsed java
         * file, we get comments and store them
         */

        for (ClassDoc classDoc : root.classes()) {

            if (classDoc.getRawCommentText().length() > 0)
                parsedComments.put(classDoc.qualifiedName(), classDoc.getRawCommentText());

            for (FieldDoc f : classDoc.enumConstants()) {
                if (f.getRawCommentText().length() > 0)
                    parsedComments.put(f.qualifiedName(), f.getRawCommentText());
            }
            for (FieldDoc f : classDoc.fields()) {
                if (f.getRawCommentText().length() > 0)
                    parsedComments.put(f.qualifiedName(), f.getRawCommentText());
            }
            for (MethodDoc m : classDoc.methods()) {
                if (m.getRawCommentText().length() > 0)
                    parsedComments.put(m.toString(), m.getRawCommentText());
            }
        }
        return true;
    }

    
    public static int check(HashMap<String, String> wantedComments) {
        int errorCount=0;
        Iterator< Entry<String, String> > it = parsedComments.entrySet().iterator();

        while (it.hasNext())
        {
            Entry<String, String> e = (Entry<String, String>) it.next();
            String actualStr = e.getValue();
            String wantedStr = wantedComments.get(e.getKey());
            // this may be weird, but I don't know any more effective solution
            actualStr = actualStr.replace(" ", "");
            actualStr = actualStr.replace("\n", "");
            actualStr = actualStr.replace("\t", "");
            if (wantedStr != null) {
                wantedStr = wantedStr.replace(" ", "");
                wantedStr = wantedStr.replace("\n", "");
                wantedStr = wantedStr.replace("\t", "");
            }

            if (!actualStr.equals(wantedStr)) {
                System.out.println("Documentation comments for " + e.getKey() + " do not match!");
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
                    gotFile.write(e.getValue());
                    gotFile.close();
                } catch (IOException ex) {
                    System.out.println("Error when writing output to file: " + ex);
                }
                
                errorCount++;
            }
        }

        if (parsedComments.size() != wantedComments.size()) {
            System.out.println("Mismatch in the number of comments!\n    Expected: " +
                               wantedComments.size() + "\n    Parsed: " +
                               parsedComments.size());
            System.out.println("Expected keys: ");
            printKeys(wantedComments);
            System.out.println("Parsed keys: ");
            printKeys(parsedComments);

            errorCount++;
        }
		
        return errorCount > 0 ? 1 : 0;
    }

    
    private static void printKeys(Map map) {
        Set<String> keys = map.keySet();
        for (String key : keys) {
            System.out.println("    " + key);
        }
    }
    
    
    public static void printCommentListForJavaSource() {
        Iterator< Entry<String, String> > it = parsedComments.entrySet().iterator();
        while (it.hasNext())
        {
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
            System.out.format("Usage:\n\tcommentParsing <package to parse>\n");
            System.exit(1);
        }
		
        com.sun.tools.javadoc.Main.execute("The comment parser program",
                                           "commentParser", new String[]{"-quiet", argv[0]});
		
        // if we are run as standalone app, print the list of found comments as it would appear in java source
		
        printCommentListForJavaSource();
    }
}
