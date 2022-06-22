import cpp11_move_only_valuewrapper.*;

public class cpp11_move_only_valuewrapper_runme {

  static {
    try {
	System.loadLibrary("cpp11_move_only_valuewrapper");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Counter.reset_counts();
    {
      XXX xxx = cpp11_move_only_valuewrapper.createXXX();
      xxx.delete();
    }
    if (cpp11_move_only_valuewrapper.has_cplusplus11())
      // Was (1, 2, 0, 0, 0, 3) before SwigValueWrapper::operator=(T &&) was added.
      // Was (1, 1, 0, 1, 0, 3) before SwigValueWrapper::operator T&&() was added with new "out" typemaps
      Counter.check_counts(1, 0, 0, 2, 0, 3);
    Counter.reset_counts();
    {
      XXX xxx = cpp11_move_only_valuewrapper.createXXX2();
      xxx.delete();
    }
    if (cpp11_move_only_valuewrapper.has_cplusplus11())
      Counter.check_counts(1, 0, 0, 2, 0, 3);
    cpp11_move_only_valuewrapper.test1();
    cpp11_move_only_valuewrapper.test2();
    cpp11_move_only_valuewrapper.test3();
    cpp11_move_only_valuewrapper.test4();
    cpp11_move_only_valuewrapper.test5();
    cpp11_move_only_valuewrapper.test6();

    // Tests SwigValueWrapper, std::unique_ptr (SWIG not parsing a type that is move-only)
    Counter.reset_counts();
    SWIGTYPE_p_std__unique_ptrT_XXX_t ptr = cpp11_move_only_valuewrapper.makeUniqueXXX();
    cpp11_move_only_valuewrapper.cleanup(ptr);
    Counter.check_counts(1, 0, 0, 0, 0, 1);
  }
}
