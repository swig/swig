
// This is the arrays runtime testcase. It ensures that a getter and a setter has 
// been produced for array members.

import arrays.*;

public class arrays_runme {

  static {
    try {
	System.loadLibrary("arrays");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    // Set values in c array
    ArrayStruct as = new ArrayStruct();
    int array_i[] = {1000, 2000}; 
    as.setArray_i(array_i);
    int[] array_i_check = as.getArray_i();

    // Check that the array values were set correctly
    for (int i=0; i<arrays.ARRAY_LEN; i++) {
      if (array_i_check[i] != array_i[i]) {
        System.err.println("Runtime test failed. array_check[" + i + "]=" + array_i_check[i]);
        System.exit(1);
      }
    }
 }
}
