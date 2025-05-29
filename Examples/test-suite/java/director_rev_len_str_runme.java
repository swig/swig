
import director_rev_len_str.*;

public class director_rev_len_str_runme {

  static {
    try {
      System.loadLibrary("director_rev_len_str");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Callback callback = new DirectorReverseLengthStringCallback();
    Caller caller = new Caller(callback);
    int sum = caller.call();

    if (sum != 9*2*8)
      throw new RuntimeException("Unexpected sum: " + sum);
  }
}

class DirectorReverseLengthStringCallback extends Callback {
  public DirectorReverseLengthStringCallback() {
    super();
  }

  @Override
  public int run(String dataBufferAA)
  {
    int ret = 0;
    if (dataBufferAA != null) {
      for (int i = 0; i < dataBufferAA.length(); i++)
        ret += (int)dataBufferAA.charAt(i) * 2;
    }
    return ret;
  }
}

