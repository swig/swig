import constructor_copy_non_const.*;

public class constructor_copy_non_const_runme {

  static {
    try {
	System.loadLibrary("constructor_copy_non_const");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    {
      CCBase2 ccb2 = new CCBase2(new CCBase2());
      CCDerived ccd = new CCDerived(new CCDerived());
      CCMoreDerived ccmd = new CCMoreDerived(new CCMoreDerived());
      CCMoreDerived2 ccmd2 = new CCMoreDerived2(new CCMoreDerived2());
      CCMoreMoreDerived2 ccmmd2 = new CCMoreMoreDerived2(new CCMoreMoreDerived2());
    }
    {
      // no copy ctor CCProtectedBase2
      CCProtectedDerived ccd = new CCProtectedDerived(new CCProtectedDerived());
      CCProtectedMoreDerived ccmd = new CCProtectedMoreDerived(new CCProtectedMoreDerived());
      CCProtectedMoreDerived2 ccmd2 = new CCProtectedMoreDerived2(new CCProtectedMoreDerived2());
      CCProtectedMoreMoreDerived2 ccmmd2 = new CCProtectedMoreMoreDerived2(new CCProtectedMoreMoreDerived2());
    }
  }
}
