
import friends_nested.*;

public class friends_nested_runme {

  static {
    try {
	System.loadLibrary("friends_nested");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    option_map om = new option_map();
    mark_t m = new mark_t();
    acc_cond ac = new acc_cond();
    more_acc_cond.squeezed_in.more_mark_t mm = new more_acc_cond.squeezed_in.more_mark_t();

    SWIGTYPE_p_std__ostream cout = friends_nested.std_cout_reference();
    friends_nested.std_cout_badbit(); // uncomment this to see std::cout
    friends_nested.operatorshift(cout, om);
    m.operatorshift(0);
    friends_nested.operatorshift(cout, m);
    friends_nested.operatorshift(cout, ac);
    friends_nested.operatorshift(cout, mm);
  }
}
