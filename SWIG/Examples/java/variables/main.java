// This example illustrates global variable access from Java.

import java.lang.reflect.*;

public class main {
  static {
    try {
        System.loadLibrary("example");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

// Try to set the values of some global variables

    example.set_ivar(42);
    example.set_svar((short)-31000);
    example.set_lvar(65537);
    example.set_uivar(123456);
    example.set_usvar(61000);
    example.set_ulvar(654321);
    example.set_scvar((byte)-13);
    example.set_ucvar((short)251);
    example.set_cvar((byte)'S');
    example.set_fvar((float)3.14159);
    example.set_dvar(2.1828);
    example.set_strvar("Hello World");
    example.set_cstrvar("Goodbye");
    example.set_iptrvar(example.new_int(37));
    example.set_ptptr(example.new_Point(37,42));
    example.set_name("Bill");

    // Now print out the values of the variables

    System.out.println( "Variables (values printed from Java)" );

    System.out.println( "ivar      =" + example.get_ivar() );
    System.out.println( "svar      =" + example.get_svar() );
    System.out.println( "lvar      =" + example.get_lvar() );
    System.out.println( "uivar     =" + example.get_uivar() );
    System.out.println( "usvar     =" + example.get_usvar() );
    System.out.println( "ulvar     =" + example.get_ulvar() );
    System.out.println( "scvar     =" + example.get_scvar() );
    System.out.println( "ucvar     =" + example.get_ucvar() );
    System.out.println( "fvar      =" + example.get_fvar() );
    System.out.println( "dvar      =" + example.get_dvar() );
    System.out.println( "cvar      =" + (char)example.get_cvar() );
    System.out.println( "strvar    =" + example.get_strvar() );
    System.out.println( "cstrvar   =" + example.get_cstrvar() );
    System.out.println( "iptrvar   =" + Long.toHexString(example.get_iptrvar()) );
    System.out.println( "name      =" + example.get_name() );
    System.out.println( "ptptr     =" + Long.toHexString(example.get_ptptr()) + example.Point_print(example.get_ptptr()) );
    System.out.println( "pt        =" + Long.toHexString(example.get_pt()) + example.Point_print(example.get_pt()) );

    System.out.println( "\nVariables (values printed from C)" );

    example.print_vars();

    System.out.println( "\nNow I'm going to try and modify some read only variables" );

    System.out.println( "     Trying to set 'path'" );
    try {
        Method m = example.class.getDeclaredMethod("set_path", new Class[] {String.class});
        m.invoke(example.class, new Object[] {"Whoa!"} );
        System.out.println( "Hey, what's going on?!?! This shouldn't work" );
    }
    catch (NoSuchMethodException e) {
        System.out.println( "Good." );
    }
    catch (Throwable t) {
        System.out.println( "You shouldn't see this!" );
    }

    System.out.println( "     Trying to set 'status'" );
    try {
        Method m = example.class.getDeclaredMethod("set_status", new Class[] {Integer.class});
        m.invoke(example.class, new Object[] {new Integer(0)} );
        System.out.println( "Hey, what's going on?!?! This shouldn't work" );
    }
    catch (NoSuchMethodException e) {
        System.out.println( "Good." );
    }
    catch (Throwable t) {
        System.out.println( "You shouldn't see this!" );
    }

    System.out.println( "\nI'm going to try and update a structure variable.\n" );

    example.set_pt(example.get_ptptr());

    System.out.println( "The new value is" );
    example.pt_print();
    System.out.println( "You should see the value" + example.Point_print(example.get_ptptr()) );
  }
}
