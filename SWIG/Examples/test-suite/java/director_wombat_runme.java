import director_wombat.*;

public class director_wombat_runme
{
  static {
    try {
        System.loadLibrary("director_wombat");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String[] args)
  {
    Bar                 b = new Bar();
    Foo_integers        a;
    int                 retval;

    a = b.meth();
    if ((retval = a.meth(49)) != 49) {
      System.out.println("Test failed: retval = " + retval + ", expected 49");
      System.exit(1);
    }

    a.delete();

    a = new Foo_integers_derived();
    if ((retval = a.meth(62)) != 62 + 2) {
      System.out.println("Test failed: retval = " + retval + ", expected 62 + 2");
      System.exit(1);
    }

    a.delete();

    a = new Foo_integers_derived_2();
    if ((retval = a.meth(37)) != 37) {
      System.out.println("Test failed: retval = " + retval + ", expected 37");
      System.exit(1);
    }
  }
}

class Foo_integers_derived extends Foo_integers
{
  public Foo_integers_derived()
  {
    super();
  }

  public int meth(int param)
  {
    return param + 2;
  }
}

class Foo_integers_derived_2 extends Foo_integers
{
  public Foo_integers_derived_2()
  {
    super();
  }
}
