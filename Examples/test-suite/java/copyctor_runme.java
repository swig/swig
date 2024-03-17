import copyctor.*;

public class copyctor_runme {

  static {
    try {
	System.loadLibrary("copyctor");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Bar bar = new Bar();
    bar = new Bar(bar);

    Foo foo = new Foo();
    foo = new Foo(bar);

    Car car = new Car();

    Hoo hoo = new Hoo();
    hoo = new Hoo(bar);
    hoo = new Hoo(car);
  }
}
