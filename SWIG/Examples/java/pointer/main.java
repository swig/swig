// file: main.java

import example;

public class main {

  static {
    try {
	System.loadLibrary("example");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
/* Not yet supported as no pointer library has been written for the Java module!
    // First create some objects using the pointer library.
    System.out.println("Testing the pointer library");
    a = example.ptrcreate("int",37);
    b = example.ptrcreate("int",42);
    c = example.ptrcreate("int");  
    
    System.out.println("     a =" + a);
    System.out.println("     b =" + b);
    System.out.println("     c =" + c);
    
    // Call the add() function with some pointers
    example.add(a,b,c);
    
    // Now get the result
    r = example.ptrvalue(c);
    System.out.println("     37 + 42 =" + r);
    
    // Clean up the pointers
    example.ptrfree(a);
    example.ptrfree(b);
    example.ptrfree(c);
*/
    // Now try the typemap library
    // This should be much easier. Now it is no longer
    // necessary to manufacture pointers.
    // Instead we use a single element array which in Java is modifiable.
    
    System.out.println("Trying the typemap library");
    int[] r = {0};
    example.sub(37,42,r);
    System.out.println("     37 - 42 = " + r[0]);
    
    // Now try the version with return value
    
    System.out.println("Testing return value");
    int q = example.divide(42,37,r);
    System.out.println("     42/37 = " + q + " remainder " + r[0]);
  }
}
