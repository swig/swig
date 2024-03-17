import cpp11_copyctor_delete.*;

public class cpp11_copyctor_delete_runme {

  static {
    try {
        System.loadLibrary("cpp11_copyctor_delete");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    // check copy constructors are generated
    new CopyCtorDeletedPublic1(CopyCtorDeletedPublic1.make());
    new CopyCtorDeletedProtected1(CopyCtorDeletedProtected1.make());
    new CopyCtorDeletedPrivate1(CopyCtorDeletedPrivate1.make());

    new DeletedPublic4();
    new DeletedPublic5();
    new CopyCtorDeletedPublic4();
    new CopyCtorDeletedPublic5();

    new StackOnly1();
    new CopyCtorStackOnly1(new CopyCtorStackOnly1());
  }
}
