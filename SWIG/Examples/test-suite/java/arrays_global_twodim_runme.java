// Two dimension arrays test

import arrays_global_twodim.*;

public class arrays_global_twodim_runme {
  static {
    try {
        System.loadLibrary("arrays_global_twodim");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
      SWIGTYPE_p_a_4__int intarray2d = arrays_global_twodim.getArray_i();

      int count = 0;
      for (int x=0; x<arrays_global_twodim.ARRAY_LEN_X; x++) {
        for (int y=0; y<arrays_global_twodim.ARRAY_LEN_Y; y++) {
          arrays_global_twodim.set_2d_array(intarray2d, x, y, count++);
        }
      }

      count = 0;
      for (int x=0; x<arrays_global_twodim.ARRAY_LEN_X; x++) {
        for (int y=0; y<arrays_global_twodim.ARRAY_LEN_Y; y++) {
          if ( arrays_global_twodim.get_2d_array(intarray2d, x, y) != count++) {
            System.out.println("Value incorrect array_i[" + x + "][" + y + "]");
            System.exit(1);
          }
        }
      }

      SWIGTYPE_p_a_4__int constintarray2d = arrays_global_twodim.getArray_const_i();
      count = 10;
      for (int x=0; x<arrays_global_twodim.ARRAY_LEN_X; x++) {
        for (int y=0; y<arrays_global_twodim.ARRAY_LEN_Y; y++) {
          if ( arrays_global_twodim.get_2d_array(constintarray2d, x, y) != count++) {
            System.out.println("Value incorrect array_const_i[" + x + "][" + y + "]");
            System.exit(1);
          }
        }
      }
  }
}
