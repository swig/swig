
// This is the java_typemaps_proxy runtime testcase. Contrived example checks that the pure Java code from the Java typemaps compiles.

import java_typemaps_proxy.*;
import java.lang.reflect.*;

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

    // No finalize method so may as well delete manually
    bye.delete();

    // Check that Greeting is derived from Exception
    try {
      throw new Greeting();
    } catch (Greeting g) {
        String msg = g.getMessage(); 
    }

    // Check that Greeting has implemented the EventListener interface
    Greeting.cheerio(greet); 

    // The default getCPtr() call in each method will through an exception if null is passed.
    // Make sure the modified version works with and without null objects.
    Greeting.ciao(null);
    Greeting.ciao(greet);

    // Create a NULL pointer for Farewell using the constructor with changed modifiers
    Farewell nullFarewell = new Farewell(0, false);

    // Test typemaps are being found for templated classes
    AdieuIntPtrPtr.adieu();

    // Check the %javamethodmodifiers feature
    try {

      Method methodmodifiertest = nullFarewell.getClass().getDeclaredMethod("methodmodifiertest", (java.lang.Class[])null);
      if ( !Modifier.isPrivate(methodmodifiertest.getModifiers()) )
        throw new RuntimeException("NS::Farewell::methodmodifiertest not private" );

    } catch (NoSuchMethodException n) {
      throw new RuntimeException("NoSuchmethodException caught. Test failed.");
    } catch (SecurityException s) {
      throw new RuntimeException("SecurityException caught. Test failed.");
    }
  }
}

