
import nested_class.*;

public class nested_class_runme {

  static {
    try {
	System.loadLibrary("nested_class");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Outer outer = new Outer();
    SWIGTYPE_p_Outer__InnerStruct1 is1 = outer.makeInnerStruct1();
    SWIGTYPE_p_Outer__InnerClass1 ic1 = outer.makeInnerClass1();
    SWIGTYPE_p_Outer__InnerUnion1 iu1 = outer.makeInnerUnion1();

    SWIGTYPE_p_Outer__InnerStruct2 is2 = outer.makeInnerStruct2();
    SWIGTYPE_p_Outer__InnerClass2 ic2 = outer.makeInnerClass2();
    SWIGTYPE_p_Outer__InnerUnion2 iu2 = outer.makeInnerUnion2();

    SWIGTYPE_p_Outer__InnerClass4Typedef ic4 = outer.makeInnerClass4Typedef();
    SWIGTYPE_p_Outer__InnerStruct4Typedef is4 = outer.makeInnerStruct4Typedef();
    SWIGTYPE_p_Outer__InnerUnion4Typedef iu4 = outer.makeInnerUnion4Typedef();

    SWIGTYPE_p_Outer__InnerClass5 ic5 = outer.makeInnerClass5();
    SWIGTYPE_p_Outer__InnerStruct5 is5 = outer.makeInnerStruct5();
    SWIGTYPE_p_Outer__InnerUnion5 iu5 = outer.makeInnerUnion5();

    ic5 = outer.makeInnerClass5Typedef();
    is5 = outer.makeInnerStruct5Typedef();
    iu5 = outer.makeInnerUnion5Typedef();

    {
      SWIGTYPE_p_Outer__InnerMultiple im1 = outer.getMultipleInstance1();
      SWIGTYPE_p_Outer__InnerMultiple im2 = outer.getMultipleInstance2();
      SWIGTYPE_p_Outer__InnerMultiple im3 = outer.getMultipleInstance3();
      SWIGTYPE_p_Outer__InnerMultiple im4 = outer.getMultipleInstance4();
    }

    {
      SWIGTYPE_p_Outer__InnerMultipleDerived im1 = outer.getMultipleDerivedInstance1();
      SWIGTYPE_p_Outer__InnerMultipleDerived im2 = outer.getMultipleDerivedInstance2();
      SWIGTYPE_p_Outer__InnerMultipleDerived im3 = outer.getMultipleDerivedInstance3();
      SWIGTYPE_p_Outer__InnerMultipleDerived im4 = outer.getMultipleDerivedInstance4();
    }

    {
      SWIGTYPE_p_Outer__InnerMultipleDerived im1 = outer.getMultipleDerivedInstance1();
      SWIGTYPE_p_Outer__InnerMultipleDerived im2 = outer.getMultipleDerivedInstance2();
      SWIGTYPE_p_Outer__InnerMultipleDerived im3 = outer.getMultipleDerivedInstance3();
      SWIGTYPE_p_Outer__InnerMultipleDerived im4 = outer.getMultipleDerivedInstance4();
    }

    {
      SWIGTYPE_p_Outer__InnerMultipleAnonTypedef1 mat1 = outer.makeInnerMultipleAnonTypedef1();
      SWIGTYPE_p_Outer__InnerMultipleAnonTypedef2 mat2 = outer.makeInnerMultipleAnonTypedef2();
      SWIGTYPE_p_Outer__InnerMultipleAnonTypedef3 mat3 = outer.makeInnerMultipleAnonTypedef3();

      SWIGTYPE_p_Outer__InnerMultipleNamedTypedef mnt = outer.makeInnerMultipleNamedTypedef();
      SWIGTYPE_p_Outer__InnerMultipleNamedTypedef mnt1 = outer.makeInnerMultipleNamedTypedef1();
      SWIGTYPE_p_Outer__InnerMultipleNamedTypedef mnt2 = outer.makeInnerMultipleNamedTypedef2();
      SWIGTYPE_p_p_Outer__InnerMultipleNamedTypedef mnt3 = outer.makeInnerMultipleNamedTypedef3();
    }
    {
      SWIGTYPE_p_Outer__InnerSameName isn = outer.makeInnerSameName();
    }
  }
}
