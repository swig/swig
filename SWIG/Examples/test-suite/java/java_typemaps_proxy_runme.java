
// This is the java_typemaps_proxy runtime testcase. Contrived example checks that the pure Java code from the Java typemaps compiles.

import java_typemaps_proxy.*;

public class java_typemaps_proxy_runme {

  static {
    try {
	System.loadLibrary("java_typemaps_proxy");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    Greeting greet = new Greeting();
    Farewell bye = new Farewell();

    // Check that pure Java methods have been added
    greet.sayhello();
    bye.saybye(new java.math.BigDecimal(java.math.BigInteger.ONE));

    // Check that Greeting is derived from Exception
    try {
      throw new Greeting();
    } catch (Greeting g) {
        String msg = g.getMessage(); 
    }

    // Check that Greeting has implemented the EventListener interface
    Greeting.cheerio(greet); 
  }
}

