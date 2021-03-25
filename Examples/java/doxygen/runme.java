// This example shows simple usage of the wrapped Shape classes.
// The main purpose of this example is to show the doxygen comments translation to JavaDoc comments.
// Users should look at the generated .java files and if javadoc is installed and working on your system,
// the generated Java docs can be viewed in a browser by opening the javadocs/index.html file.

import java.io.*;

public class runme {
  static {
    try {
        System.loadLibrary("example");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) throws InterruptedException, IOException
  {
    System.out.println("Creating some objects:");
    Circle c = example.MakeCircle(10);
    System.out.println("    Created circle " + c);
    Square s = example.MakeSquare(10);
    System.out.println("    Created square " + s);
    RectangleInt r = example.MakeRectangleInt(10, 20);
    System.out.println("    Created rectangle " + r);

    System.out.println("\nHere are some properties of the shapes:");
    Shape[] shapes = {c, s, r};
    for (int i=0; i<shapes.length; i++) {
      System.out.println("   " + shapes[i].toString());
      System.out.println("        area      = " + shapes[i].area());
      System.out.println("        perimeter = " + shapes[i].perimeter());
    }

    String command = "javadoc -quiet -public -d javadocs example.java Shape.java Circle.java Square.java RectangleInt.java";
    System.out.println("\nRunning: " + command);
    Process p = Runtime.getRuntime().exec(command);
    int exitCode = p.waitFor();
    System.out.println("javadoc exited with code " + exitCode);

    BufferedReader stdout = new BufferedReader(new InputStreamReader(p.getInputStream()));
    BufferedReader stderr = new BufferedReader(new InputStreamReader(p.getErrorStream()));

    String line = null;

    System.out.println("stdout from javadoc:\n");
    while ((line = stdout.readLine()) != null) {
      System.out.println(line);
    }

    System.out.println("\nstderr from javadoc:\n");
    while ((line = stderr.readLine()) != null) {
      System.out.println(line);
    }

    if (exitCode != 0) {
      System.out.println("No java docs were generated!\n");
    } else {
      System.out.println("javadoc ran successfully, open javadocs/index.html in your browser to view the generated java docs.");
    }
  }
}
