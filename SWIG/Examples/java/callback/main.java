public class main
{
  static {
    try {
        System.loadLibrary("example");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String[] args)
  {
    System.out.println("Adding and calling a normal C++ callback");
    System.out.println("----------------------------------------");

    Caller              caller = new Caller();
    Callback            callback = new Callback();
    
    caller.setCallback(callback);
    caller.call();
    caller.delCallback();

    // Unlike Python, Java does not automatically support "weak"
    // references (*), so we're left with managing the memory.
    //
    // (*) Yes, there is a WeakReference class, but it doesn't
    // work exactly the way the Python weak reference works.

    callback.delete();

    callback = new JavaCallback();

    System.out.println();
    System.out.println("Adding and calling a Java callback");
    System.out.println("------------------------------------");

    caller.setCallback(callback);
    caller.call();
    caller.delCallback();

    callback.delete();

    System.out.println();
    System.out.println("java exit");
  }
}

class JavaCallback extends Callback
{
  public JavaCallback()
  {
    super();
  }

  public void run()
  {
    System.out.println("JavaCallback.run()");
  }
}

