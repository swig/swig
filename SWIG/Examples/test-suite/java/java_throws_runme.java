
import java_throws.*;

public class java_throws_runme {

  static {
    try {
        System.loadLibrary("java_throws");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
      // Check the exception classes in the main typemaps
      boolean pass = false;

      // This won't compile unless all of these exceptions are in the throw clause
      try {
        short s = java_throws.full_of_exceptions(10);
      }
      catch (ClassNotFoundException e) {}
      catch (NoSuchFieldException e) { pass = true; }
      catch (InstantiationException e) {}
      catch (CloneNotSupportedException e) {}
      catch (IllegalAccessException e) {}

      if (!pass) {
        System.err.println("Test 1 failed");
        System.exit(1);
      }

      // Check the exception class in the throw typemap
      try {
        java_throws.throw_spec_function(100);
      }
      catch (IllegalAccessException e) { pass = true; }

      if (!pass) {
        System.err.println("Test 2 failed");
        System.exit(1);
      }
  }
}
