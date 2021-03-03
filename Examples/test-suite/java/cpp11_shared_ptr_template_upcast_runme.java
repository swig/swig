// This is the cpp11_shared_ptr_template_upcast runtime testcase. It checks that SWIG generates the appropriate upcasted shared_ptr type for a template instantiation deriving from a base class.
// For this case, the expected behavior is: given a cptr with underlying type shared_ptr<Printable<Derived> >, PrintableDerived_SWIGSmartPtrUpcast returns a cptr with 
// underlying type std::shared_ptr< Derived >, where Printable<Derived> inherits from Derived.

import cpp11_shared_ptr_template_upcast.*;

public class cpp11_shared_ptr_template_upcast_runme {

  static {
    try {
	System.loadLibrary("cpp11_shared_ptr_template_upcast");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    PrintableDerived pd = cpp11_shared_ptr_template_upcast.MakePrintableDerived(20);
    pd.GetResult();
    pd.GetFormatted();
  }
}

