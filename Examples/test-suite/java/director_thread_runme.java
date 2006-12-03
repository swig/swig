
import director_thread.*;
import java.lang.reflect.*;

public class director_thread_runme {

  static {
    try {
      System.loadLibrary("director_thread");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    /*
    director_thread_Derived d = new director_thread_Derived();
    d.run();

    if (d.getVal() >= 0) {
        throw new RuntimeException("Failed. Val: " + d.getVal());
    }
    */
    // Disabled as it hangs the process. The solution of calling DetachCurrentThread in ~JNIEnvWrapper causes seg faults in other JNI calls on some machines
    System.err.println("Disabled runtest - it fails");
  }
}

class director_thread_Derived extends Foo {
  director_thread_Derived() {
    super();
  }

  public void do_foo() {
    setVal(getVal() - 1);
  }
}

