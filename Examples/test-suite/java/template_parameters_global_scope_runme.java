import template_parameters_global_scope.*;

public class template_parameters_global_scope_runme {

  static {
    try {
      System.loadLibrary("template_parameters_global_scope");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    int alloc = 0;

    // Check 1
    alloc = template_parameters_global_scope.Bucket1();
    alloc = template_parameters_global_scope.Bucket2();
    alloc = template_parameters_global_scope.Bucket3();
    alloc = template_parameters_global_scope.Bucket4();
    alloc = template_parameters_global_scope.Bucket5();
    alloc = template_parameters_global_scope.Bucket6();

    // Check 2
    alloc = template_parameters_global_scope.Spade1();
    alloc = template_parameters_global_scope.Spade2();
    alloc = template_parameters_global_scope.Spade3();
    alloc = template_parameters_global_scope.Spade4();
    alloc = template_parameters_global_scope.Spade5();
    alloc = template_parameters_global_scope.Spade6();

    // Check 3
    alloc = template_parameters_global_scope.Ball1();
    alloc = template_parameters_global_scope.Ball2();
    alloc = template_parameters_global_scope.Ball3();
    alloc = template_parameters_global_scope.Ball4();
    alloc = template_parameters_global_scope.Ball5();
    alloc = template_parameters_global_scope.Ball6();

    // Check 4
    alloc = template_parameters_global_scope.Bat1();
    alloc = template_parameters_global_scope.Bat2();
    alloc = template_parameters_global_scope.Bat3();
    alloc = template_parameters_global_scope.Bat4();
    alloc = template_parameters_global_scope.Bat5();
    alloc = template_parameters_global_scope.Bat6();

    // Check 5
    alloc = template_parameters_global_scope.Chair1();
    alloc = template_parameters_global_scope.Chair2();
    alloc = template_parameters_global_scope.Chair3();
    alloc = template_parameters_global_scope.Chair4();
    alloc = template_parameters_global_scope.Chair5();
    alloc = template_parameters_global_scope.Chair6();

    // Check 6
    alloc = template_parameters_global_scope.Table1();
    alloc = template_parameters_global_scope.Table2();
    alloc = template_parameters_global_scope.Table3();
    alloc = template_parameters_global_scope.Table4();
    alloc = template_parameters_global_scope.Table5();
    alloc = template_parameters_global_scope.Table6();

    /*
    alloc = template_parameters_global_scope.rejig1();
    alloc = template_parameters_global_scope.rejig2();
    alloc = template_parameters_global_scope.rejig3();
    alloc = template_parameters_global_scope.rejig4();
    alloc = template_parameters_global_scope.rejig5();
    alloc = template_parameters_global_scope.rejig6();
    */
  }
}
