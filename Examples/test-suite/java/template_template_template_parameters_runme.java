

import template_template_template_parameters.*;

public class template_template_template_parameters_runme {

  static {
    try {
	System.loadLibrary("template_template_template_parameters");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    CustomAttrs custom_attrs = new CustomAttrs();
    AC ac = new AC();
    BAC bac = new BAC();
    CBAC cbac = new CBAC();
    DBAC dbac = new DBAC();

    custom_attrs = ac.getAttributes();
    custom_attrs = bac.getAttributes();
    custom_attrs = cbac.getAttributes();
    custom_attrs = dbac.getAttributes();

    bac.BMethod(custom_attrs, ac);
    cbac.BMethod(custom_attrs, ac);
    dbac.BMethod(custom_attrs, ac);

    cbac.CMethod(custom_attrs, bac);
    dbac.DMethod(custom_attrs, bac);
  }
}

