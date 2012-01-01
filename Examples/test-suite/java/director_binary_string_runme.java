
import director_binary_string.*;

public class director_binary_string_runme {

  static {
    try {
      System.loadLibrary("director_binary_string");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Caller caller = new Caller();
    Callback callback = new DirectorBinaryStringCallback();
    caller.setCallback(callback);
    int sum = caller.call();
    caller.delCallback();

    if (sum != 9*2*8 + 13*3*5)
      throw new RuntimeException("Unexpected sum: " + sum);
  }
}

class DirectorBinaryStringCallback extends Callback {
  public DirectorBinaryStringCallback() {
    super();
  }

  @Override
  public void run(byte[] dataBufferAA, byte[] dataBufferBB)
  {
    for (int i = 0; i < dataBufferAA.length; i++)
      dataBufferAA[i] = (byte)(dataBufferAA[i] * 2);

    for (int i = 0; i < dataBufferBB.length; i++)
      dataBufferBB[i] = (byte)(dataBufferBB[i] * 3);
  }
}

