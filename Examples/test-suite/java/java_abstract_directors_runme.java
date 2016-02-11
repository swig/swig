import java_abstract_directors.*;
import java.lang.reflect.*;
import java.util.HashSet;
import java.util.Set;

public class java_abstract_directors_runme {
  static {
    try {
      System.loadLibrary("java_abstract_directors");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  static void throwIfFalse(boolean b) throws Exception {
    if (!b) throw new Exception();
  }

  public static void main(String argv[]) {
    Class[] empty = (Class[]) null;
    String reason = "no reason";

    try {
      reason = "Director1::Method1 abstract director failed";
      throwIfFalse(Modifier.isAbstract(Director1.class.getDeclaredMethod("Method1", empty).getModifiers()));

      reason = "Director1::Method2 abstract director failed";
      throwIfFalse(!Modifier.isAbstract(Director1.class.getDeclaredMethod("Method2", empty).getModifiers()));

      reason = "Director1.Director1 abstract director failed";
      throwIfFalse(Modifier.isAbstract(Director1.class.getModifiers()));

      reason = "Director2::Method1 abstract director failed";
      throwIfFalse(Modifier.isAbstract(Director2.class.getDeclaredMethod("Method1", empty).getModifiers()));

      reason = "Director2::Method2 abstract director failed";
      throwIfFalse(!Modifier.isAbstract(Director2.class.getDeclaredMethod("Method2", empty).getModifiers()));

      reason = "Director2.Director2 abstract director failed";
      throwIfFalse(Modifier.isAbstract(Director2.class.getModifiers()));

      reason = "Director3::Method1 abstract director failed";
      throwIfFalse(!Modifier.isAbstract(Director3.class.getDeclaredMethod("Method1", empty).getModifiers()));

      reason = "Director3::Method2 abstract director failed";
      throwIfFalse(!Modifier.isAbstract(Director3.class.getDeclaredMethod("Method2", empty).getModifiers()));

      reason = "Director3.Director3 abstract director failed";
      throwIfFalse(!Modifier.isAbstract(Director3.class.getModifiers()));

      reason = "Director4::Method1 abstract director failed";
      throwIfFalse(Modifier.isAbstract(Director4.class.getDeclaredMethod("Method1", empty).getModifiers()));

      reason = "Director4::Method2 abstract director failed";
      throwIfFalse(!Modifier.isAbstract(Director4.class.getDeclaredMethod("Method2", empty).getModifiers()));

      reason = "Director4.Director4 abstract director failed";
      throwIfFalse(Modifier.isAbstract(Director4.class.getModifiers()));

      Set<String> names = new HashSet<String>();
      for (Method m : java_abstract_directorsJNI.class.getDeclaredMethods()) {
        names.add(m.getName());
      }

      reason = "java_abstract_directorsJNI.Director1_Method1 abstract director failed";
      throwIfFalse(!names.contains("Director1_Method1"));

      reason = "java_abstract_directorsJNI.Director1_Method2 abstract director failed";
      throwIfFalse(names.contains("Director1_Method2"));

      reason = "java_abstract_directorsJNI.Director2_Method1 abstract director failed";
      throwIfFalse(!names.contains("Director2_Method1"));

      reason = "java_abstract_directorsJNI.Director2_Method2 abstract director failed";
      throwIfFalse(names.contains("Director2_Method2"));

      reason = "java_abstract_directorsJNI.Director3_Method1 abstract director failed";
      throwIfFalse(names.contains("Director3_Method1"));

      reason = "java_abstract_directorsJNI.Director3_Method2 abstract director failed";
      throwIfFalse(names.contains("Director3_Method2"));

      reason = "java_abstract_directorsJNI.Director4_Method1 abstract director failed";
      throwIfFalse(!names.contains("Director4_Method1"));

      reason = "java_abstract_directorsJNI.Director4_Method2 abstract director failed";
      throwIfFalse(names.contains("Director4_Method2"));
    } catch (Exception e) {
      throw new RuntimeException(reason);
    }
  }
}
