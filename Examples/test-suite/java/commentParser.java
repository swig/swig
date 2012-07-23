
import com.sun.javadoc.*;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Iterator;

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
				System.out.println("Documentation comments for " + e.getKey() + " does not match: ");
				// here we print original strings, for nicer output
				System.out.println("\texpected:"+wantedComments.get(e.getKey()));
				System.out.println("\tgot:\t"+e.getValue());
				errorCount++;
			}
		}

		if (parsedComments.size() < wantedComments.size()) {
			System.out.println("Found " + (wantedComments.size()-parsedComments.size()) + " missed comment(s)!");
			errorCount++;
		}
		
		return errorCount;
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
