import li_carrays.*;

public class li_carrays_runme {

  static {
    try {
        System.loadLibrary("li_carrays");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) throws Throwable
  {
    int length = 5;

    // array_class
    {
      XYArray xyArray = new XYArray(length);
      for (int i=0; i<length; i++) {
        XY xy = xyArray.getitem(i);
        xy.setX(i*10);
        xy.setY(i*100);
        xyArray.setitem(i, xy);
      }
      for (int i=0; i<length; i++) {
        Assert(xyArray.getitem(i).getX(), i*10);
        Assert(xyArray.getitem(i).getY(), i*100);
      }
    }

    // array_functions
    {
      AB abArray = li_carrays.new_ABArray(length);
      for (int i=0; i<length; i++) {
        AB ab = li_carrays.ABArray_getitem(abArray, i);
        ab.setA(i*10);
        ab.setB(i*100);
        li_carrays.ABArray_setitem(abArray, i, ab);
      }
      for (int i=0; i<length; i++) {
        Assert(li_carrays.ABArray_getitem(abArray, i).getA(), i*10);
        Assert(li_carrays.ABArray_getitem(abArray, i).getB(), i*100);
      }
      li_carrays.delete_ABArray(abArray);
    }
  }

  private static void Assert(int val1, int val2) {
//      System.out.println("val1=" + val1 + " val2=" + val2);
    if (val1 != val2)
      throw new RuntimeException("Mismatch. val1=" + val1 + " val2=" + val2);
  }
}
