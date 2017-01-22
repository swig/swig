
import extend_template_method.*;

public class extend_template_method_runme {

  static {
    try {
	System.loadLibrary("extend_template_method");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    {
      ExtendMe em = new ExtendMe();

      {
        double ret_double = em.do_stuff_double(1, 1.1);
        if (ret_double != 1.1)
          throw new RuntimeException("double failed " + ret_double);
        String ret_string = em.do_stuff_string(1, "hello there");
        if (!ret_string.equals("hello there"))
          throw new RuntimeException("string failed " + ret_string);
      }
      {
        double ret_double = em.do_overloaded_stuff(1.1);
        if (ret_double != 1.1)
          throw new RuntimeException("double failed " + ret_double);
        String ret_string = em.do_overloaded_stuff("hello there");
        if (!ret_string.equals("hello there"))
          throw new RuntimeException("string failed " + ret_string);
      }
    }
    {
      TemplateExtend em = new TemplateExtend();

      {
        double ret_double = em.do_template_stuff_double(1, 1.1);
        if (ret_double != 1.1)
          throw new RuntimeException("double failed " + ret_double);
        String ret_string = em.do_template_stuff_string(1, "hello there");
        if (!ret_string.equals("hello there"))
          throw new RuntimeException("string failed " + ret_string);
      }
      {
        double ret_double = em.do_template_overloaded_stuff(1.1);
        if (ret_double != 1.1)
          throw new RuntimeException("double failed " + ret_double);
        String ret_string = em.do_template_overloaded_stuff("hello there");
        if (!ret_string.equals("hello there"))
          throw new RuntimeException("string failed " + ret_string);
      }
    }
  }
}
