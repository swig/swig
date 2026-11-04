
import template_arg_names.*;

public class template_arg_names_runme {

  static {
    try {
	System.loadLibrary("template_arg_names");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Second second = new Second();
    second.setValue(5);

    PairSecond pair = new PairSecond();
    pair.setFirst(second);
    pair.setSecond(10);
    if (pair.copy_first().getValue() != 5)
      throw new RuntimeException("copy_first failed");
    if (pair.getSecond() != 10)
      throw new RuntimeException("getSecond failed");
    if (template_arg_names.first_value(pair) != 5)
      throw new RuntimeException("first_value failed");
    pair.setLink(pair);
    if (pair.this_pair().getLink().copy_first().getValue() != 5)
      throw new RuntimeException("this_pair failed");

    if (template_arg_names.pick_first_second(second, 10).getValue() != 5)
      throw new RuntimeException("pick_first_second failed");

    First first = new First();
    first.setValue(2);
    PairSwap swapped = new PairSwap();
    swapped.setFirst(second);
    swapped.setSecond(first);
    if (swapped.copy_first().getValue() != 5)
      throw new RuntimeException("swapped copy_first failed");
    if (swapped.getSecond().getValue() != 2)
      throw new RuntimeException("swapped getSecond failed");
    if (template_arg_names.swapped_value(swapped) != 7)
      throw new RuntimeException("swapped_value failed");
  }
}
