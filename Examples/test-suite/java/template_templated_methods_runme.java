
import template_templated_methods.*;

public class template_templated_methods_runme {

  static {
    try {
	System.loadLibrary("template_templated_methods");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // assign test
    {
      OctetVector ov = new OctetVector();
      octet o = new octet(111);
      ov.add(o);
      SimpleContainer sc = new SimpleContainer(ov);
      OctetResourceLimitedVector orlv = new OctetResourceLimitedVector();
      orlv.assign(sc.begin(), sc.end());
      OctetVector collection = orlv.getCollection();
      if (collection.size() != 1)
        throw new RuntimeException("wrong size");
      octet oo = collection.get(0);
      if (oo.getNum() != 111)
        throw new RuntimeException("wrong val");
    }
    // assign_and_append test
    {
      OctetVector ov = new OctetVector();
      octet o = new octet(222);
      ov.add(o);
      SimpleContainer sc = new SimpleContainer(ov);
      OctetResourceLimitedVector orlv = new OctetResourceLimitedVector();
      octet final_octet = new octet(333);
      orlv.assign_and_append(sc.begin(), sc.end(), final_octet);
      OctetVector collection = orlv.getCollection();
      if (collection.size() != 2)
        throw new RuntimeException("wrong size");
      octet oo = collection.get(0);
      if (oo.getNum() != 222)
        throw new RuntimeException("wrong val");
      oo = collection.get(1);
      if (oo.getNum() != 333)
        throw new RuntimeException("wrong finalval");
    }
  }
}
